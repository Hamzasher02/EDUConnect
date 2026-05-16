enum AttendanceStatus { present, absent, leave, late }

class AttendanceRecordModel {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNo;
  final String classId;
  final String subject; // Optional, for subject-wise attendance
  final DateTime date;
  AttendanceStatus status;
  final String? remarks;
  final String recordedBy; // Teacher ID

  AttendanceRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.classId,
    this.subject = '',
    required this.date,
    this.status = AttendanceStatus.present,
    this.remarks,
    required this.recordedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'rollNo': rollNo,
    'classId': classId,
    'subject': subject,
    'date': date.toIso8601String(),
    'status': status.name,
    'remarks': remarks,
    'recordedBy': recordedBy,
  };

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      rollNo: json['rollNo'],
      classId: json['classId'],
      subject: json['subject'] ?? '',
      date: DateTime.parse(json['date']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.present,
      ),
      remarks: json['remarks'],
      recordedBy: json['recordedBy'],
    );
  }

  AttendanceRecordModel copyWith({AttendanceStatus? status, String? remarks}) {
    return AttendanceRecordModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      rollNo: rollNo,
      classId: classId,
      subject: subject,
      date: date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      recordedBy: recordedBy,
    );
  }
}
