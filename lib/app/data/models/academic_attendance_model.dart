enum SubjectAttendanceStatus { present, absent, leave }

class AttendanceAuditLog {
  final String teacherId;
  final DateTime timestamp;
  final SubjectAttendanceStatus previousStatus;
  final SubjectAttendanceStatus newStatus;

  AttendanceAuditLog({
    required this.teacherId,
    required this.timestamp,
    required this.previousStatus,
    required this.newStatus,
  });

  Map<String, dynamic> toJson() => {
    'teacherId': teacherId,
    'timestamp': timestamp.toIso8601String(),
    'previousStatus': previousStatus.name,
    'newStatus': newStatus.name,
  };

  factory AttendanceAuditLog.fromJson(Map<String, dynamic> json) =>
      AttendanceAuditLog(
        teacherId: json['teacherId'] ?? '',
        timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        previousStatus: SubjectAttendanceStatus.values.firstWhere(
          (e) => e.name == json['previousStatus'],
          orElse: () => SubjectAttendanceStatus.absent,
        ),
        newStatus: SubjectAttendanceStatus.values.firstWhere(
          (e) => e.name == json['newStatus'],
          orElse: () => SubjectAttendanceStatus.present,
        ),
      );
}

class SubjectAttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String subjectId;
  final String teacherId;
  final DateTime date;
  final SubjectAttendanceStatus status;
  final List<AttendanceAuditLog> history;
  final DateTime updatedAt;

  SubjectAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.date,
    required this.status,
    this.history = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'date': date.toIso8601String(),
    'status': status.name,
    'history': history.map((e) => e.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SubjectAttendanceRecord.fromJson(Map<String, dynamic> json) =>
      SubjectAttendanceRecord(
        id: json['id'] ?? '',
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        classId: json['classId'] ?? '',
        subjectId: json['subjectId'] ?? '',
        teacherId: json['teacherId'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        status: SubjectAttendanceStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SubjectAttendanceStatus.present,
        ),
        history: (json['history'] as List? ?? [])
            .map((e) => AttendanceAuditLog.fromJson(e))
            .toList(),
        updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
      );

  SubjectAttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? classId,
    String? subjectId,
    String? teacherId,
    DateTime? date,
    SubjectAttendanceStatus? status,
    List<AttendanceAuditLog>? history,
    DateTime? updatedAt,
  }) {
    return SubjectAttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      status: status ?? this.status,
      history: history ?? this.history,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AttendanceGridModel {
  final List<DateTime> dates; // Days of the month
  final List<StudentAttendanceRow> rows;

  AttendanceGridModel({required this.dates, required this.rows});
}

class StudentAttendanceRow {
  final String studentId;
  final String studentName;
  final Map<int, SubjectAttendanceRecord> dailyRecords; // day -> record

  StudentAttendanceRow({
    required this.studentId,
    required this.studentName,
    required this.dailyRecords,
  });

  int get totalPresent => dailyRecords.values
      .where((r) => r.status == SubjectAttendanceStatus.present)
      .length;
  int get totalDays => dailyRecords.length;
  double get attendancePercentage =>
      totalDays > 0 ? (totalPresent / totalDays) * 100 : 0;
}
