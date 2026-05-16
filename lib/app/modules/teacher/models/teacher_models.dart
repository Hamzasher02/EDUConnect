import '../../../data/models/attendance_record_model.dart'; // Import for usage
export '../../../data/models/student_model.dart';
export '../../../data/models/assignment_model.dart';
export '../../../data/models/messaging/message_model.dart';
export '../../../data/models/attendance_record_model.dart';
export '../../school_admin/models/school_admin_models.dart'; // For ClassTimetableSlotModel and others if needed

class StudentAttendanceModel {
  final String id;
  final String name;
  final String rollNo;
  AttendanceStatus status;
  final String? photoUrl;

  StudentAttendanceModel({
    required this.id,
    required this.name,
    required this.rollNo,
    this.status = AttendanceStatus.present,
    this.photoUrl,
  });
}

class StudentMarksModel {
  final String id;
  final String name;
  final String rollNo;
  String midtermMarks;
  String finalMarks;
  final String? photoUrl;

  StudentMarksModel({
    required this.id,
    required this.name,
    required this.rollNo,
    this.midtermMarks = '',
    this.finalMarks = '',
    this.photoUrl,
  });
}

class FilterOptions {
  final String? classId;
  final String? subject;
  final String? day;
  final bool? completed;

  FilterOptions({this.classId, this.subject, this.day, this.completed});

  FilterOptions copyWith({
    String? classId,
    String? subject,
    String? day,
    bool? completed,
  }) => FilterOptions(
    classId: classId ?? this.classId,
    subject: subject ?? this.subject,
    day: day ?? this.day,
    completed: completed ?? this.completed,
  );

  static FilterOptions initial() => FilterOptions();
}
