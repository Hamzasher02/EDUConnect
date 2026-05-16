class StudentResultModel {
  final String id;
  final String studentId;
  final String examName;
  final String subject;
  final double totalMarks;
  final double obtainedMarks;
  final String? remarks;
  final DateTime examDate;

  StudentResultModel({
    required this.id,
    required this.studentId,
    required this.examName,
    required this.subject,
    required this.totalMarks,
    required this.obtainedMarks,
    this.remarks,
    required this.examDate,
  });

  double get percentage => (obtainedMarks / totalMarks) * 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'examName': examName,
    'subject': subject,
    'totalMarks': totalMarks,
    'obtainedMarks': obtainedMarks,
    'remarks': remarks,
    'examDate': examDate.toIso8601String(),
  };

  factory StudentResultModel.fromJson(Map<String, dynamic> json) {
    return StudentResultModel(
      id: json['id'],
      studentId: json['studentId'],
      examName: json['examName'],
      subject: json['subject'],
      totalMarks: (json['totalMarks'] as num).toDouble(),
      obtainedMarks: (json['obtainedMarks'] as num).toDouble(),
      remarks: json['remarks'],
      examDate: DateTime.parse(json['examDate']),
    );
  }
}

class ExamSummaryModel {
  final String examName;
  final double totalObtained;
  final double totalPossible;
  final List<StudentResultModel> subjectResults;
  final DateTime examDate;
  final int? rank;
  final int? totalStudents;

  ExamSummaryModel({
    required this.examName,
    required this.totalObtained,
    required this.totalPossible,
    required this.subjectResults,
    required this.examDate,
    this.rank,
    this.totalStudents,
  });

  double get percentage => (totalObtained / totalPossible) * 100;
}
