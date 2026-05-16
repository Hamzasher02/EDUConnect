import 'package:get/get.dart';
import '../services/teacher_dashboard_service.dart';
import '../../school_admin/models/school_admin_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class TeacherTimetableController extends GetxController {
  final _dashboardService = Get.find<TeacherDashboardService>();
  final _authService = Get.find<AuthService>();

  // --- State ---
  // Bind to service state directly if possible, or maintain local reactive list
  RxList<ClassTimetableSlotModel> get fullTimetable =>
      _dashboardService.teacherTimetable;

  final isLoading = false.obs;
  final filteredTimetable = <ClassTimetableSlotModel>[].obs;

  List<SubjectModel> getSubjectsForClass(String classNum) {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return [];
    return Get.find<SchoolDataService>()
        .getSubjectsBySchool(session.schoolId!)
        .where(
          (s) => s.classId == classNum || s.name.contains(classNum),
        ) // classNum might be "9" or an ID
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    // No need to fetch manually if we bind, but for now we call it
    fetchTimetable();
  }

  void filterTimetable({String? day, String? subject, String? classId}) {
    final schoolDataService = Get.find<SchoolDataService>();
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    final allItems = schoolDataService.getTeacherTimetable(
      session.schoolId!,
      session.userId,
    );

    filteredTimetable.assignAll(
      allItems.where((slot) {
        bool matches = true;
        if (day != null && day.isNotEmpty) matches = matches && slot.day == day;
        if (subject != null && subject.isNotEmpty) {
          matches =
              matches &&
              slot.subjectName.toLowerCase().contains(subject.toLowerCase());
        }
        if (classId != null && classId.isNotEmpty) {
          final cleanClassId = classId.replaceAll('Class ', '');
          matches = matches && slot.classNumber == cleanClassId;
        }
        return matches;
      }).toList(),
    );
  }

  void fetchTimetable() {
    isLoading.value = true;
    try {
      filterTimetable(); // Initial load
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timetable: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ClassTimetableSlotModel> getTimetableForDay(String day) {
    return fullTimetable.where((slot) => slot.day == day).toList();
  }

  // --- CRUD Methods ---
  Future<void> addTimetableEntry(
    String classNum,
    String subject,
    String day,
    String start,
    String end,
    String room,
  ) async {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    final subjects = getSubjectsForClass(classNum);
    final subjectObj = subjects.firstWhereOrNull((s) => s.name == subject);

    final newSlot = ClassTimetableSlotModel(
      id: '', // Firestore gen
      classId: classNum,
      classNumber: classNum,
      subjectId: subjectObj?.id ?? subject,
      subjectName: subject,
      day: day,
      startTime: start,
      endTime: end,
      roomNumber: room,
      teacherId: session.userId,
      teacherName: session.name ?? 'Teacher',
    );

    try {
      final schoolDataService = Get.find<SchoolDataService>();
      await schoolDataService.addTimetableSlot(session.schoolId!, newSlot);

      // Auto-assign subject to all students in this class (consistency with Admin)
      try {
        await schoolDataService.assignSubjectToStudentsInClass(
          session.schoolId!,
          classNum,
          newSlot.subjectId,
        );
      } catch (e) {
        print(
          'DEBUG (TeacherTimetable): Auto-assignment non-critical error: $e',
        );
      }

      // Auto-assign teacher to this subject/class
      try {
        await schoolDataService.ensureTeacherAssignment(
          schoolId: session.schoolId!,
          teacherId: session.userId,
          teacherName: session.name ?? 'Teacher',
          classNumber: classNum,
          subjectId: newSlot.subjectId,
          subjectName: newSlot.subjectName,
        );
      } catch (e) {
        print(
          'DEBUG (TeacherTimetable): Teacher auto-assignment non-critical error: $e',
        );
      }

      Get.back(); // Close dialog
      Get.snackbar('Success', 'Class added successfully');
      filterTimetable(); // Refresh
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateTimetableEntry(
    String id,
    String classNum,
    String subject,
    String day,
    String start,
    String end,
    String room,
  ) async {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    final subjects = getSubjectsForClass(classNum);
    final subjectObj = subjects.firstWhereOrNull((s) => s.name == subject);

    final slot = ClassTimetableSlotModel(
      id: id,
      classId: classNum,
      classNumber: classNum,
      subjectId: subjectObj?.id ?? subject,
      subjectName: subject,
      day: day,
      startTime: start,
      endTime: end,
      roomNumber: room,
      teacherId: session.userId,
      teacherName: session.name ?? 'Teacher',
    );

    try {
      final schoolDataService = Get.find<SchoolDataService>();
      await schoolDataService.updateTimetableSlot(session.schoolId!, slot);
      Get.back(); // Close dialog
      Get.snackbar('Success', 'Class updated successfully');
      filterTimetable();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteTimetableEntry(String id) async {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    try {
      final schoolDataService = Get.find<SchoolDataService>();
      await schoolDataService.deleteTimetableSlot(session.schoolId!, id);
      Get.snackbar('Deleted', 'Class removed successfully');
      filterTimetable();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
