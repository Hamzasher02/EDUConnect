class StudentDashboardData {
  final String studentName;
  final String? profilePhoto;
  final String className;
  final String section;
  final double attendancePercentage;
  final String overallPerformance; // e.g., "A", "85%"
  final List<StudentClassItem> todaysClasses;
  final List<StudentClassItem> upcomingClasses;
  final String? feeSummary;
  final int pendingAssignmentsCount;
  final List<String> subjects;

  StudentDashboardData({
    required this.studentName,
    this.profilePhoto,
    required this.className,
    required this.section,
    required this.attendancePercentage,
    required this.overallPerformance,
    required this.todaysClasses,
    required this.upcomingClasses,
    this.feeSummary,
    required this.pendingAssignmentsCount,
    required this.subjects,
  });

  String get attendanceLabel {
    if (attendancePercentage >= 0.85) return 'Excellent';
    if (attendancePercentage >= 0.70) return 'Good';
    return 'Poor';
  }
}

class StudentClassItem {
  final String subject;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String room;

  StudentClassItem({
    required this.subject,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
  });
}
