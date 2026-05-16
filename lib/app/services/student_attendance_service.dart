import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../modules/student/models/attendance_models.dart';
import '../data/models/attendance_record_model.dart'; // Unified model
import '../data/enums/app_enums.dart'; // For UserRole

class StudentAttendanceService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession(String studentId) {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
    if (session.userId != studentId) {
      throw 'Ownership validation failed';
    }
  }

  Future<List<SubjectAttendanceSummary>> getSubjectWiseSummaries(
    String studentId,
  ) async {
    _validateSession(studentId);

    final allAtt = _schoolDataService.getStudentAttendance(studentId);

    // Group by Subject
    final Map<String, List<AttendanceRecordModel>> grouped = {};
    for (var att in allAtt) {
      final key = att.subject.isEmpty ? 'General' : att.subject;
      grouped.putIfAbsent(key, () => []).add(att);
    }

    return grouped.entries.map((entry) {
      final subject = entry.key;
      final subjectAtt = entry.value;

      int total = subjectAtt.length;
      int present = subjectAtt
          .where((a) => a.status == AttendanceStatus.present)
          .length;
      int absent = subjectAtt
          .where((a) => a.status == AttendanceStatus.absent)
          .length;
      int leave = subjectAtt
          .where((a) => a.status == AttendanceStatus.leave)
          .length;

      double percentage = 0;
      if (total > 0) {
        percentage = (present / total) * 100;
      }

      return SubjectAttendanceSummary(
        subject: subject,
        totalClasses: total,
        presentCount: present,
        absentCount: absent,
        leaveCount: leave,
        percentage: percentage,
      );
    }).toList();
  }

  Future<List<MonthlyAttendanceSummary>> getMonthlyAttendanceSummaries(
    String studentId,
  ) async {
    _validateSession(studentId);

    final allAtt = _schoolDataService.getStudentAttendance(studentId);
    // allAtt is List<AttendanceRecordModel>

    // Group by Month/Year
    final Map<String, List<AttendanceRecordModel>> grouped = {};
    for (var att in allAtt) {
      final key = '${att.date.year}-${att.date.month}';
      grouped.putIfAbsent(key, () => []).add(att);
    }

    final summaries = grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthAtt = entry.value;

      int present = monthAtt
          .where((a) => a.status == AttendanceStatus.present)
          .length;
      int absent = monthAtt
          .where((a) => a.status == AttendanceStatus.absent)
          .length;
      int leave = monthAtt
          .where((a) => a.status == AttendanceStatus.leave)
          .length;

      double percentage = 0;
      if (present + absent > 0) {
        percentage = (present / (present + absent)) * 100;
      } else if (present > 0 || leave > 0) {
        percentage = 100; // Only present or leave days
      }

      return MonthlyAttendanceSummary(
        month: month,
        year: year,
        percentage: percentage,
        presentCount: present,
        absentCount: absent,
        leaveCount: leave,
      );
    }).toList();

    // Sort by Date Descending
    summaries.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return summaries;
  }

  Future<List<AttendanceRecordModel>> getAttendanceByMonth(
    String studentId,
    int month,
    int year,
  ) async {
    _validateSession(studentId);

    final allAtt = _schoolDataService.getStudentAttendance(studentId);
    return allAtt
        .where((a) => a.date.month == month && a.date.year == year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
