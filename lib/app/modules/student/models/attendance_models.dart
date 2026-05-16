class MonthlyAttendanceSummary {
  final int month;
  final int year;
  final double percentage;
  final int presentCount;
  final int absentCount;
  final int leaveCount;

  MonthlyAttendanceSummary({
    required this.month,
    required this.year,
    required this.percentage,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
  });

  String get monthName {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class SubjectAttendanceSummary {
  final String subject;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final double percentage;

  SubjectAttendanceSummary({
    required this.subject,
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.percentage,
  });
}
