import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/teacher_models.dart';
import '../services/teacher_dashboard_service.dart';
import '../../../data/models/student_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../data/models/academic_attendance_model.dart' as academic;
import '../../../theme/app_colors.dart';

class TeacherStudentController extends GetxController {
  final _dashboardService = Get.find<TeacherDashboardService>();
  final _authService = Get.find<AuthService>();

  final searchResults = <StudentModel>[].obs;
  final selectedStudentClass = ''.obs;
  final studentsForSelectedClass = <StudentModel>[].obs;
  final isLoading = false.obs;

  Future<void> searchStudents(String query, {String? classId}) async {
    searchResults.assignAll(
      await _dashboardService.searchStudents(query, classId: classId),
    );
  }

  Future<void> fetchStudents(String classId) async {
    selectedStudentClass.value = classId;
    isLoading.value = true;
    try {
      final students = await _dashboardService.getStudentsForClass(classId);
      studentsForSelectedClass.assignAll(students);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStudent(String name, String rollNo) async {
    if (selectedStudentClass.value.isEmpty) {
      Get.snackbar('Error', 'No class selected');
      return;
    }

    final newStudent = StudentModel(
      id: 'stu_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: _authService.session.value?.schoolId ?? 'school_001',
      name: name,
      rollNo: rollNo,
      classNumber: selectedStudentClass.value,
      email: '', // Mock
      password: '', // Mock
      createdAt: DateTime.now(),
      parentEmail: '',
      parentCnic: '',
    );

    try {
      await _dashboardService.addStudentToClass(
        selectedStudentClass.value,
        newStudent,
      );
      Get.back(); // Close dialog
      Get.snackbar('Success', 'Student added successfully');
      fetchStudents(selectedStudentClass.value); // Refresh list
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void removeStudent(String studentId) {
    if (selectedStudentClass.value.isEmpty) return;
    try {
      _dashboardService.removeStudentFromClass(
        selectedStudentClass.value,
        studentId,
      );
      Get.snackbar('Deleted', 'Student removed');
      fetchStudents(selectedStudentClass.value);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> markAttendanceAccordingToTimetable(
    StudentModel student, {
    academic.SubjectAttendanceStatus status = academic.SubjectAttendanceStatus.present,
  }) async {
    final schoolId = _authService.session.value?.schoolId;
    if (schoolId == null) return;

    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now); // e.g. "Monday"
    final currentTimeStr = DateFormat('HH:mm').format(now);

    // 1. Find active slot from timetable
    final activeSlot = _dashboardService.teacherTimetable.firstWhereOrNull((slot) {
      if (slot.day.toLowerCase() != dayName.toLowerCase()) return false;
      
      try {
        final start = slot.startTime.trim();
        final end = slot.endTime.trim();
        return currentTimeStr.compareTo(start) >= 0 && currentTimeStr.compareTo(end) <= 0;
      } catch (e) {
        return false;
      }
    });

    // 2. Fallback to formal assignments if no specific time slot is active
    final assignments = _dashboardService.getAssignedClasses()
        .where((a) => a.classNumber == student.classNumber)
        .toList();

    if (activeSlot == null && assignments.isEmpty) {
      Get.snackbar(
        'No Active Class',
        'No scheduled class or assignment found for ${student.name} at this time.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    final String subjectName = activeSlot?.subjectName ?? assignments.first.subjectName;

    try {
      final schoolDataService = Get.find<SchoolDataService>();
      final record = academic.SubjectAttendanceRecord(
        id: '', 
        studentId: student.id,
        studentName: student.name,
        classId: student.classNumber,
        subjectId: subjectName,
        teacherId: _authService.session.value!.userId,
        date: now,
        status: status,
        updatedAt: now,
      );

      await schoolDataService.saveSubjectAttendance(schoolId, record);
      
      final color = status == academic.SubjectAttendanceStatus.present
          ? Colors.green
          : (status == academic.SubjectAttendanceStatus.absent ? Colors.red : Colors.orange);

      Get.snackbar(
        'Attendance Marked',
        '${student.name} marked ${status.name.toUpperCase()} for $subjectName',
        backgroundColor: color.withValues(alpha: 0.8),
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark attendance: $e');
    }
  }
}
