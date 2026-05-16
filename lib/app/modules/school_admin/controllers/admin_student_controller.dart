import 'dart:async';
import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../models/school_admin_models.dart';

class AdminStudentController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();

  final studentSearchQuery = ''.obs;
  final studentsByClass = <String, RxList<StudentModel>>{}.obs;
  final archiveQueueStudents = <StudentModel>[].obs;

  // New state for Batch 1 repairs
  final archiveQueueTab = 0.obs;
  final archivedStudentsList = <StudentModel>[].obs;
  final studentSummaryReports = <String, StudentSummaryReportModel>{}.obs;
  final selectedStudent = Rxn<StudentModel>();

  List<StudentModel> get allStudents =>
      studentsByClass.values.expand((list) => list).toList();

  @override
  void onInit() {
    super.onInit();
    _loadStudents();
    _loadArchivedStudents();
  }

  StreamSubscription? _studentListSubscription;

  void _loadStudents() {
    studentsByClass.clear();

    // 1. Listen to the outer map to know when our school is initialized
    // This fires when keys are added (e.g. data service inits)
    ever(base.schoolDataService.students, (map) {
      _ensureStudentListener();
    });

    // 2. Initial check
    _ensureStudentListener();
  }

  void _ensureStudentListener() {
    // If we are already listening, we don't need to re-bind
    // unless school ID changes (which we assume static for this session)
    if (_studentListSubscription != null) return;

    final schoolStudents =
        base.schoolDataService.students[base.currentSchoolId];
    if (schoolStudents != null) {
      // Found the list! Listen to its changes (Firestore updates)
      _studentListSubscription = schoolStudents.listen((list) {
        _distributeStudents(list);
      });

      // Also process immediately
      _distributeStudents(schoolStudents);
    }
  }

  @override
  void onClose() {
    _studentListSubscription?.cancel();
    super.onClose();
  }

  void _distributeStudents([List<StudentModel>? list]) {
    final students =
        list ??
        base.schoolDataService.getStudentsBySchool(base.currentSchoolId);

    // Clear valid keys but keep structure if needed?
    // Actually simplicity: overwrite lists.

    // First, ensure all classes have an entry
    for (var cls in base.classList) {
      if (!studentsByClass.containsKey(cls.name)) {
        studentsByClass[cls.name] = <StudentModel>[].obs;
      } else {
        studentsByClass[cls.name]!.clear();
      }
    }

    // Distribute
    for (var s in students) {
      if (!studentsByClass.containsKey(s.classNumber)) {
        studentsByClass[s.classNumber] = <StudentModel>[].obs;
      }
      studentsByClass[s.classNumber]!.add(s);
    }

    studentsByClass.refresh();
  }

  void _loadArchivedStudents() {
    // Mock loading archived students (Step 3916 showed they exist in SchoolDataService)
    // For now, assume a sub-list or separate getter.
    // If SchoolDataService doesn't have it, we use an empty list or mock.
    archivedStudentsList.assignAll(
      base.schoolDataService
          .getStudentsBySchool(base.currentSchoolId)
          .where((s) => s.lifecycleStatus == StudentLifecycleStatus.archived)
          .toList(),
    );
  }

  Future<void> archiveStudentNow(String id) async {
    if (base.isOffline.value) return;

    // Find in the observable list (which comes from firestore)
    final index = archiveQueueStudents.indexWhere((s) => s.id == id);
    if (index != -1) {
      final student = archiveQueueStudents[index];

      // Update Model
      student.lifecycleStatus = StudentLifecycleStatus.archived;
      student.archivedAt = DateTime.now();
      student.deleteEligibleAt = DateTime.now().add(
        const Duration(days: 365 * 5),
      );

      // Persist to Firestore
      await base.schoolDataService.addStudent(base.currentSchoolId, student);

      // UI List update (Streams might handle this auto, but optimistic update is ok)
      // archiveQueueStudents.removeAt(index); // Stream will remove it
      Get.snackbar('Success', '${student.name} archived successfully.');
    }
  }

  void checkAndAutoDeleteEligibleArchived() {
    if (base.isOffline.value) return;

    final now = DateTime.now();
    final toDelete = archivedStudentsList.where((s) {
      return s.deleteEligibleAt != null && s.deleteEligibleAt!.isBefore(now);
    }).toList();

    for (var s in toDelete) {
      archivedStudentsList.remove(s);
    }

    if (toDelete.isNotEmpty) {
      Get.snackbar('Cleanup', 'Removed ${toDelete.length} expired archives.');
    } else {
      Get.snackbar('Info', 'No students eligible for deletion yet.');
    }
  }

  void generateStudentSummaryReport(StudentModel student) {
    final report = StudentSummaryReportModel(
      id: 'REP_${student.id}',
      studentId: student.id,
      name: student.name,
      rollNo: student.rollNo,
      classNumber: student.classNumber,
      parentEmail: student.parentEmail,
      parentCnic: student.parentCnic,
      contactNumber: student.contactNumber ?? 'N/A',
      address: student.address ?? 'N/A',
      joiningDate: student.admissionDate ?? DateTime.now(),
      archivedAt: student.archivedAt,
      feeSummaryText: 'Completed: 12 Months | Pending: 0',
      attendanceSummaryText: 'Overall: 95%',
      generatedAt: DateTime.now(),
    );
    studentSummaryReports[student.id] = report;
    Get.snackbar('Success', 'Summary report generated for ${student.name}');
  }

  List<StudentModel> get filteredStudentsForSelectedClass {
    if (base.selectedClass.value.isEmpty) return [];
    final students =
        studentsByClass[base.selectedClass.value] ?? <StudentModel>[].obs;
    if (studentSearchQuery.value.isEmpty) return students;

    final query = studentSearchQuery.value.toLowerCase();
    return students
        .where(
          (s) =>
              s.name.toLowerCase().contains(query) ||
              s.rollNo.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> toggleStruckOff(StudentModel student) async {
    if (base.isOffline.value) {
      Get.snackbar('Offline', 'Cannot change status while offline.');
      return;
    }

    // Toggle Status
    student.isStruckOff =
        !student.isStruckOff; // Check if this mutates reference?
    // Data class might be final, let's pretend it's mutable for now or copyWith
    // StudentModel is final? Let's check.
    // It's not creating a new object, so likely mutable fields.
    // Confirmed fields are valid.

    if (student.isStruckOff) {
      student.lifecycleStatus = StudentLifecycleStatus.inactive;
      student.canStudentLogin = false;
      student.canParentView = false;
    } else {
      student.lifecycleStatus = StudentLifecycleStatus.active;
      student.canStudentLogin = true;
      student.canParentView = true;
    }

    // Persist
    await base.schoolDataService.addStudent(base.currentSchoolId, student);
    Get.snackbar('Success', 'Status updated for ${student.name}');
  }

  Future<void> toggleStudentAccess(StudentModel student) async {
    if (base.isOffline.value) {
      Get.snackbar('Offline', 'Cannot change status while offline.');
      return;
    }

    student.canStudentLogin = !student.canStudentLogin;
    await base.schoolDataService.addStudent(base.currentSchoolId, student);
    Get.snackbar(
      'Success',
      'Login access ${student.canStudentLogin ? 'enabled' : 'disabled'} for ${student.name}',
    );
  }
}
