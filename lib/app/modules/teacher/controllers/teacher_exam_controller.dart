import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/school_data_service.dart';
import '../../../services/auth_service.dart';
import '../../school_admin/models/school_admin_models.dart';

class TeacherExamController extends GetxController {
  final SchoolDataService _schoolDataService = Get.find<SchoolDataService>();
  final AuthService _authService = Get.find<AuthService>();

  final scheduledExams = <UnifiedExamModel>[].obs;
  final isLoading = false.obs;

  // Form State
  final selectedClass = ''.obs;
  final selectedSubject = ''.obs;
  final examName = 'Class Test'.obs;
  final examDate = DateTime.now().obs;
  final startTime = const TimeOfDay(hour: 9, minute: 0).obs;
  final examType = ExamType.quiz.obs;

  List<String> get uniqueAssignedClasses {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return [];

    final timetables = _schoolDataService.getTeacherTimetable(
      session.schoolId!,
      session.userId,
    );
    final assignments = _schoolDataService
        .getTeacherAssignmentsBySchool(session.schoolId!)
        .where((a) => a.teacherId == session.userId);

    final Set<String> classes = timetables.map((s) => s.classNumber).toSet();
    classes.addAll(assignments.map((a) => a.classNumber));

    final list = classes.toList();
    list.sort();
    return list;
  }

  List<String> getSubjectsForClass(String classNumber) {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return [];

    final timetables = _schoolDataService.getTeacherTimetable(
      session.schoolId!,
      session.userId,
    );
    final assignments = _schoolDataService
        .getTeacherAssignmentsBySchool(session.schoolId!)
        .where((a) => a.teacherId == session.userId);

    final Set<String> subjects = timetables
        .where((s) => s.classNumber == classNumber)
        .map((s) => s.subjectName)
        .toSet();
    subjects.addAll(
      assignments
          .where((a) => a.classNumber == classNumber)
          .map((a) => a.subjectName),
    );

    final list = subjects.toList();
    list.sort();
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    final session = _authService.session.value;
    if (session != null && session.schoolId != null) {
      final examsList = _schoolDataService.exams[session.schoolId!];
      if (examsList != null) {
        ever(examsList, (_) => loadMyExams());
      }
    }
    ever(selectedClass, (String classNum) {
      selectedSubject.value = '';
    });
    loadMyExams();
  }

  void loadMyExams() {
    final session = _authService.session.value;
    if (session == null) return;

    final exams = _schoolDataService.getTeacherExams(
      session.schoolId!,
      session.userId,
    );
    scheduledExams.assignAll(exams);
  }

  Future<void> submitExam() async {
    final session = _authService.session.value;
    if (session == null) return;

    if (selectedClass.value.isEmpty || selectedSubject.value.isEmpty) {
      Get.snackbar('Error', 'Please select class and subject.');
      return;
    }

    try {
      isLoading.value = true;
      final newExam = UnifiedExamModel(
        id: '', // Firestore will generate
        examName: examName.value,
        classNumber: selectedClass.value,
        subject: selectedSubject.value,
        examDate: examDate.value,
        startTime: '${startTime.value.hour}:${startTime.value.minute}',
        endTime:
            '${startTime.value.hour + 1}:${startTime.value.minute}', // Default 1hr
        type: examType.value,
        teacherName: session.name ?? 'Teacher',
      );

      await _schoolDataService.addExamsBatch(session.schoolId!, [newExam]);

      Get.back();
      Get.snackbar('Success', 'Exam scheduled successfully');
      loadMyExams();
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule exam: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExam(String id) async {
    final session = _authService.session.value;
    if (session == null) return;

    try {
      await _schoolDataService.deleteExam(session.schoolId!, id);
      loadMyExams();
      Get.snackbar('Success', 'Exam deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete exam: $e');
    }
  }
}
