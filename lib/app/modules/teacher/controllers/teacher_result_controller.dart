import 'package:get/get.dart';
import '../models/teacher_models.dart';
import '../services/teacher_dashboard_service.dart';
import 'teacher_controller.dart';
import '../../../data/models/result_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class TeacherResultController extends GetxController {
  final isLoading = false.obs;
  final studentsMarks = <StudentMarksModel>[].obs;
  final selectedClassId = ''.obs;
  final selectedSubjectName = ''.obs;

  final _dashboardService = Get.find<TeacherDashboardService>();

  // Dependency on TeacherController for offline status
  final TeacherController _teacherController = Get.find<TeacherController>();
  RxBool get isOffline => _teacherController.isOffline;
  List<ClassTimetableSlotModel> get assignedClasses {
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    final Map<String, ClassTimetableSlotModel> uniqueMap = {};

    for (var slot in timetable) {
      final key = '${slot.classNumber}_${slot.subjectName}';
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = slot;
      }
    }

    for (var assignment in assigned) {
      final key = '${assignment.classNumber}_${assignment.subjectName}';
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = ClassTimetableSlotModel(
          id: assignment.id,
          classId: assignment.classNumber,
          classNumber: assignment.classNumber,
          day: '',
          subjectId: assignment.subjectName,
          subjectName: assignment.subjectName,
          teacherId: assignment.teacherId,
          teacherName: '',
          startTime: '',
          endTime: '',
          roomNumber: '',
        );
      }
    }

    final list = uniqueMap.values.toList();
    list.sort((a, b) => a.classNumber.compareTo(b.classNumber));
    return list;
  }

  Future<void> fetchStudents(String classId, String subjectName) async {
    selectedClassId.value = classId;
    selectedSubjectName.value = subjectName;
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final schoolId = authService.session.value?.schoolId ?? '';
      
      final students = await _dashboardService.getStudentsForClass(classId);
      final existingResults = Get.find<SchoolDataService>().getResultsForClass(
        schoolId,
        classId,
        subjectName,
      );

      final marksList = students.map((s) {
        final midterm = existingResults.firstWhereOrNull(
          (r) => r.studentId == s.id && r.examName == 'Midterm',
        );
        final finalExam = existingResults.firstWhereOrNull(
          (r) => r.studentId == s.id && r.examName == 'Final',
        );

        return StudentMarksModel(
          id: s.id,
          name: s.name,
          rollNo: s.rollNo,
          photoUrl: s.photoUrl,
          midtermMarks: midterm?.marksObtained.toString() ?? '',
          finalMarks: finalExam?.marksObtained.toString() ?? '',
        );
      }).toList();

      studentsMarks.assignAll(marksList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitResults() async {
    if (isOffline.value) {
      Get.snackbar('Error', 'Cannot submit results while offline');
      return;
    }

    // Validation
    for (var student in studentsMarks) {
      if (student.midtermMarks.isEmpty || student.finalMarks.isEmpty) {
        Get.snackbar('Error', 'Please enter marks for all students');
        return;
      }
      final mid = double.tryParse(student.midtermMarks);
      final fin = double.tryParse(student.finalMarks);

      if (mid == null || fin == null) {
        Get.snackbar('Error', 'Marks must be numeric');
        return;
      }

      if (mid < 0 || mid > 100 || fin < 0 || fin > 100) {
        Get.snackbar('Error', 'Marks must be between 0 and 100');
        return;
      }
    }

    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final schoolDataService = Get.find<SchoolDataService>();
      final session = authService.session.value;
      if (session == null || session.schoolId == null) {
        throw 'No active session or school';
      }

      final resultsList = studentsMarks.expand((s) {
        final records = <ResultModel>[];
        if (s.midtermMarks.isNotEmpty) {
          records.add(
            ResultModel(
              id: '',
              studentId: s.id,
              studentName: s.name,
              rollNo: s.rollNo,
              classId: selectedClassId.value,
              subject: selectedSubjectName.value, // Used selectedSubjectName
              examName: 'Midterm',
              marksObtained: double.parse(s.midtermMarks),
              recordedAt: DateTime.now(),
            ),
          );
        }
        if (s.finalMarks.isNotEmpty) {
          records.add(
            ResultModel(
              id: '',
              studentId: s.id,
              studentName: s.name,
              rollNo: s.rollNo,
              classId: selectedClassId.value,
              subject: selectedSubjectName.value, // Used selectedSubjectName
              examName: 'Final',
              marksObtained: double.parse(s.finalMarks),
              recordedAt: DateTime.now(),
            ),
          );
        }
        return records;
      }).toList();

      await schoolDataService.addResultsBatch(session.schoolId!, resultsList);

      // --- SEND NOTIFICATIONS TO STUDENTS ---
      for (var res in resultsList) {
        final notification = NotificationModel(
          id: '',
          title: '${res.examName} Result: ${res.subject}',
          message:
              'Your ${res.examName} marks for ${res.subject} have been recorded: ${res.marksObtained}/100',
          timestamp: DateTime.now(),
          type: NotificationType.exam,
          audience: NotificationAudience.specificStudent,
          targetId: res.studentId,
          senderId: session.userId,
        );
        await schoolDataService.addNotification(
          session.schoolId!,
          notification,
        );
      }

      Get.snackbar('Success', 'Results submitted successfully');
      Get.back(); // Go back to classes list
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
