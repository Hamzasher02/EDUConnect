class StudentExamModel {
  final String examId;
  final String examName;
  final String subject;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String? location;
  final String examType; // Term / Unit / Final
  final String? teacherName;
  final String? instructions;

  StudentExamModel({
    required this.examId,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.examType,
    this.teacherName,
    this.instructions,
  });

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'examName': examName,
    'subject': subject,
    'examDate': examDate.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'location': location,
    'examType': examType,
    'teacherName': teacherName,
    'instructions': instructions,
  };

  factory StudentExamModel.fromJson(Map<String, dynamic> json) {
    return StudentExamModel(
      examId: json['examId'],
      examName: json['examName'],
      subject: json['subject'],
      examDate: DateTime.parse(json['examDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      examType: json['examType'],
      teacherName: json['teacherName'],
      instructions: json['instructions'],
    );
  }
}
