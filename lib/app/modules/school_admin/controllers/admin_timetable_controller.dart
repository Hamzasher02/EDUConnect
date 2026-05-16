import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../routes/app_routes.dart';

class AdminTimetableController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();

  final selectedTimetableClass = ''.obs;
  final timetableSelectedDay = 'Mon'.obs;
  final slotsByClass = <String, RxList<ClassTimetableSlotModel>>{}.obs;

  // Props for TeacherTimetableView
  final timetableSubject = ''.obs;
  final timetableRoom = ''.obs;
  final teacherAssignments = <String, List<ClassTimetableSlotModel>>{}.obs;

  // No need for local slotsByClass, use Service's reactive map
  // However, UI might depend on slotsByClass. Let's redirect getters.

  List<SubjectModel> get currentClassSubjects {
    if (selectedTimetableClass.value.isEmpty) return [];
    return base.schoolDataService
        .getSubjectsBySchool(base.currentSchoolId)
        .where((s) => s.classId == selectedTimetableClass.value)
        .toList();
  }

  List<ClassTimetableSlotModel> get currentDaySlots {
    if (selectedTimetableClass.value.isEmpty) return [];

    // Get all slots for the school
    final allSlots = base.schoolDataService.getTimetable(base.currentSchoolId);

    // Filter by class and day
    return allSlots
        .where(
          (s) =>
              s.classNumber == selectedTimetableClass.value &&
              s.day == timetableSelectedDay.value,
        )
        .toList();
  }

  void goToClassTimetable(String classNumber) {
    selectedTimetableClass.value = classNumber;
    // No seeding needed, data comes from Firestore stream
    Get.toNamed(AppRoutes.adminClassTimetable); // Ensure route name correct
  }

  Future<void> addTimetableSlot({
    required String subjectId,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required String start,
    required String end,
    required String room,
  }) async {
    print(
      'DEBUG: Adding Timetable Slot - Subject: $subjectName, Teacher: $teacherName ($teacherId)',
    );
    if (base.isOffline.value) {
      print('DEBUG: Offline mode, skipping add.');
      return;
    }

    final clz = selectedTimetableClass.value;
    print('DEBUG: Class: $clz, Day: ${timetableSelectedDay.value}');

    final newSlot = ClassTimetableSlotModel(
      id: '', // Firestore gen
      classId: clz,
      classNumber: clz,
      day: timetableSelectedDay.value,
      subjectId: subjectId,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherName: teacherName,
      startTime: start,
      endTime: end,
      roomNumber: room,
    );

    try {
      print('DEBUG: Calling SchoolDataService.addTimetableSlot...');
      await base.schoolDataService.addTimetableSlot(
        base.currentSchoolId,
        newSlot,
      );

      // Auto-assign subject to all students in this class
      try {
        await base.schoolDataService.assignSubjectToStudentsInClass(
          base.currentSchoolId,
          clz,
          subjectId,
        );
        print('DEBUG: Subject $subjectName auto-assigned to students in $clz');
      } catch (ae) {
        print('DEBUG: Auto-assignment non-critical error: $ae');
      }

      // Auto-assign teacher to this subject/class
      try {
        await base.schoolDataService.ensureTeacherAssignment(
          schoolId: base.currentSchoolId,
          teacherId: teacherId,
          teacherName: teacherName,
          classNumber: clz,
          subjectId: subjectId,
          subjectName: subjectName,
        );
        print('DEBUG: Teacher $teacherName auto-linked to $clz - $subjectName');
      } catch (te) {
        print('DEBUG: Teacher auto-assignment non-critical error: $te');
      }

      print('DEBUG: Slot added successfully. Closing bottom sheet.');
      Get.back();
      Get.snackbar('Success', 'Slot added and Subject assigned to class');
    } catch (e) {
      print('DEBUG: ERROR adding slot: $e');
      Get.snackbar('Error', 'Failed to add slot: $e');
    }
  }

  Future<void> removeAssignedClass(String teacherId, String slotId) async {
    if (base.isOffline.value) return;
    await base.schoolDataService.deleteTimetableSlot(
      base.currentSchoolId,
      slotId,
    );
  }

  Future<void> removeTimetableSlot(String id) async {
    if (base.isOffline.value) return;
    await base.schoolDataService.deleteTimetableSlot(base.currentSchoolId, id);
    Get.snackbar('Success', 'Slot removed');
  }

  Future<void> updateTimetableSlot({
    required String slotId,
    required String subjectId,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required String start,
    required String end,
    required String room,
    required String classNumber,
    required String day,
  }) async {
    if (base.isOffline.value) return;

    final updatedSlot = ClassTimetableSlotModel(
      id: slotId,
      classId: classNumber, // Assuming classNumber is used as ID or consistent
      classNumber: classNumber,
      day: day,
      subjectId: subjectId,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherName: teacherName,
      startTime: start,
      endTime: end,
      roomNumber: room,
    );

    try {
      await base.schoolDataService.updateTimetableSlot(
        base.currentSchoolId,
        updatedSlot,
      );
      Get.back();
      Get.snackbar('Success', 'Slot updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update slot: $e');
    }
  }

  void saveTimetableChanges() {
    // Real-time: changes are saved immediately on add/remove
    if (base.isOffline.value) return;
    Get.snackbar('Info', 'Changes are saved automatically');
  }
}
