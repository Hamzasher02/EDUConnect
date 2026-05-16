import '../enums/app_enums.dart';

class UnifiedExamModel {
  final String id;
  final String examName;
  final String classNumber;
  final String subject;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String? location;
  final ExamType type;
  final String? teacherName;
  final String? instructions;
  final String? academicYear;

  UnifiedExamModel({
    required this.id,
    required this.examName,
    required this.classNumber,
    required this.subject,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.type,
    this.teacherName,
    this.instructions,
    this.academicYear,
  });

  bool get isCompleted {
    final now = DateTime.now();
    return examDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'examName': examName,
    'classNumber': classNumber,
    'subject': subject,
    'examDate': examDate.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'location': location,
    'type': type.name,
    'teacherName': teacherName,
    'instructions': instructions,
    'academicYear': academicYear,
  };

  factory UnifiedExamModel.fromJson(Map<String, dynamic> json) {
    return UnifiedExamModel(
      id: json['id'],
      examName: json['examName'],
      classNumber: json['classNumber'],
      subject: json['subject'],
      examDate: DateTime.parse(json['examDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      type: ExamType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExamType.term,
      ),
      teacherName: json['teacherName'],
      instructions: json['instructions'],
      academicYear: json['academicYear'],
    );
  }
}
