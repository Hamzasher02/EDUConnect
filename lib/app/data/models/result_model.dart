class ResultModel {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNo;
  final String classId;
  final String subject;
  final String examName;
  final double marksObtained;
  final double totalMarks;
  final String? remarks;
  final DateTime recordedAt;

  ResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.classId,
    required this.subject,
    required this.examName,
    required this.marksObtained,
    this.totalMarks = 100,
    this.remarks,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'rollNo': rollNo,
    'classId': classId,
    'subject': subject,
    'examName': examName,
    'marksObtained': marksObtained,
    'totalMarks': totalMarks,
    'remarks': remarks,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory ResultModel.fromJson(Map<String, dynamic> json) => ResultModel(
    id: json['id'] ?? '',
    studentId: json['studentId'] ?? '',
    studentName: json['studentName'] ?? '',
    rollNo: json['rollNo'] ?? '',
    classId: json['classId'] ?? '',
    subject: json['subject'] ?? '',
    examName: json['examName'] ?? '',
    marksObtained: (json['marksObtained'] as num? ?? 0).toDouble(),
    totalMarks: (json['totalMarks'] as num? ?? 100).toDouble(),
    remarks: json['remarks'],
    recordedAt: json['recordedAt'] != null
        ? DateTime.parse(json['recordedAt'])
        : DateTime.now(),
  );
  String get grade {
    final percentage = (marksObtained / totalMarks) * 100;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}
