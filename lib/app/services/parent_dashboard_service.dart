import 'package:get/get.dart';
import '../data/models/student_model.dart';
import '../data/models/fee_model.dart';
import '../data/models/attendance_record_model.dart';
import '../data/models/exam_model.dart';
import '../data/enums/app_enums.dart';
import 'school_data_service.dart';
import '../modules/student/models/result_models.dart'; // Added import for result models

/// Parent Dashboard Service - Manages parent's view of student data
/// All data is READ-ONLY for parents
class ParentDashboardService extends GetxService {
  // Currently selected student for parent viewing
  final Rx<StudentModel?> selectedStudent = Rx<StudentModel?>(null);

  /// Select a student for viewing (after parent login)
  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
  }

  /// Switch to a different student without logout
  void switchStudent(StudentModel newStudent) {
    selectedStudent.value = newStudent;
  }

  /// Get currently selected student
  StudentModel? getSelectedStudent() {
    return selectedStudent.value;
  }

  /// Get student fees (READ-ONLY)
  Future<List<FeeRecordModel>> getStudentFees(String studentId) async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      // Explicit cast to ensure type safety if mismatch occurs between typedefs
      return schoolDataService.getStudentFees(studentId).cast<FeeRecordModel>();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch fees: $e');
      return [];
    }
  }

  /// Calculate total dues
  Future<double> getTotalDues(String studentId) async {
    try {
      final fees = await getStudentFees(studentId);
      double total = 0;
      for (var f in fees) {
        if (f.status == FeeStatus.pending || f.status == FeeStatus.overdue) {
          total += f.remainingAmount;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get student attendance records (READ-ONLY)
  Future<List<AttendanceRecordModel>> getStudentAttendance(
    String studentId,
  ) async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      return schoolDataService.getStudentAttendance(studentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance: $e');
      return [];
    }
  }

  /// Calculate attendance percentage for a specific month
  Future<double> getMonthlyAttendancePercentage(
    String studentId,
    int year,
    int month,
  ) async {
    try {
      final records = await getStudentAttendance(studentId);
      final monthRecords = records.where((r) {
        return r.date.year == year && r.date.month == month;
      }).toList();

      if (monthRecords.isEmpty) return 0;

      final presentCount = monthRecords
          .where((r) => r.status == AttendanceStatus.present)
          .length;
      return (presentCount / monthRecords.length) * 100;
    } catch (e) {
      return 0;
    }
  }

  /// Get student results (READ-ONLY)
  Future<List<ExamSummaryModel>> getStudentResults(String studentId) async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      final resultsRaw = schoolDataService.getStudentResults(studentId);
      final results = resultsRaw
          .map(
            (e) => StudentResultModel(
              id: e.id,
              studentId: e.studentId,
              examName: e.examName,
              subject: e.subject,
              totalMarks: e.totalMarks,
              obtainedMarks: e.marksObtained,
              remarks: e.remarks,
              examDate: e.recordedAt,
            ),
          )
          .toList();

      // Group results by examName
      final Map<String, List<StudentResultModel>> grouped = {};
      for (var res in results) {
        if (!grouped.containsKey(res.examName)) {
          grouped[res.examName] = [];
        }
        grouped[res.examName]!.add(res);
      }

      final List<ExamSummaryModel> summaries = [];
      grouped.forEach((examName, subjectResults) {
        double totalObtained = 0;
        double totalPossible = 0;
        for (var res in subjectResults) {
          totalObtained += res.obtainedMarks;
          totalPossible += res.totalMarks;
        }

        summaries.add(
          ExamSummaryModel(
            examName: examName,
            totalObtained: totalObtained,
            totalPossible: totalPossible,
            subjectResults: subjectResults,
            examDate: subjectResults.first.examDate,
          ),
        );
      });

      // Sort by date latest first
      summaries.sort((a, b) => b.examDate.compareTo(a.examDate));

      return summaries;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch results: $e');
      return [];
    }
  }

  /// Get student exams
  Future<List<UnifiedExamModel>> getStudentExamSchedule(
    String studentId,
  ) async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      final rawExams = schoolDataService.getStudentExams(studentId);
      return rawExams;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch exam schedule: $e');
      return [];
    }
  }

  /// Get student timetable (READ-ONLY)
  Future<Map<String, List<Map<String, dynamic>>>> getStudentTimetable(
    String studentId,
  ) async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      final student = _getStudentById(studentId);
      if (student == null) return {};

      final allSlots = schoolDataService.getTimetable(student.schoolId);

      // Filter for student's class
      final classSlots = allSlots
          .where((s) => s.classNumber == student.classNumber)
          .toList();

      // Group by day
      final Map<String, List<Map<String, dynamic>>> grouped = {
        'Monday': [],
        'Tuesday': [],
        'Wednesday': [],
        'Thursday': [],
        'Friday': [],
        'Saturday': [],
        'Sunday': [],
      };

      for (var slot in classSlots) {
        if (grouped.containsKey(slot.day)) {
          grouped[slot.day]!.add({
            'subject': slot.subjectName,
            'teacher': slot.teacherName,
            'time': '${slot.startTime} - ${slot.endTime}',
            'room': slot.roomNumber,
            // store raw start time for sorting if needed
            'rawStart': slot.startTime,
          });
        }
      }
      return grouped;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch timetable: $e');
      return {};
    }
  }

  StudentModel? _getStudentById(String studentId) {
    if (selectedStudent.value?.id == studentId) return selectedStudent.value;
    // Fallback: search in linked students via ParentControler?
    // Or better: access SchoolDataService to find student.
    // Since we are in Service, we can find student using SchoolDataService logic if we had schoolId.
    // But parent might have students in multiple schools.
    // For now, rely on selectedStudent or ParentController context.
    // Actually, safest is to use the selectedStudent if matches, or fetch fresh.
    return selectedStudent.value;
  }

  /// Get today's classes for student
  Future<List<Map<String, dynamic>>> getTodaysClasses(String studentId) async {
    try {
      final timetable = await getStudentTimetable(studentId);
      final today = DateTime.now();
      final dayName = _getDayName(today.weekday);
      return timetable[dayName] ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Helper to get day name from weekday number
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1]; // weekday is 1-7
  }

  /// Clear selected student (on logout)
  void clearSelection() {
    selectedStudent.value = null;
  }
}
