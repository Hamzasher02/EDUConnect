enum SubmissionStatus { pending, submitted, graded }

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String classId;
  final String subjectId;
  final String? fileUrl;
  final DateTime submittedAt;
  final SubmissionStatus status;
  final double? marksObtained;
  final double maxMarks;
  final String? feedback;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.subjectId,
    this.fileUrl,
    required this.submittedAt,
    this.status = SubmissionStatus.submitted,
    this.marksObtained,
    required this.maxMarks,
    this.feedback,
  });

  factory SubmissionModel.fromJson(
    Map<String, dynamic> json,
  ) => SubmissionModel(
    id: json['id'] ?? '',
    assignmentId: json['assignmentId'],
    studentId: json['studentId'],
    studentName: json['studentName'] ?? '',
    classId: json['classId'] ?? '',
    subjectId: json['subjectId'] ?? '',
    fileUrl: json['fileUrl'],
    submittedAt: DateTime.parse(
      json['submittedAt'] ??
          json['submissionDate'] ??
          DateTime.now().toIso8601String(),
    ),
    status: SubmissionStatus.values.firstWhere(
      (e) =>
          e.name == (json['status']?.toString().toLowerCase() ?? 'submitted'),
      orElse: () => SubmissionStatus.submitted,
    ),
    marksObtained: (json['marksObtained'] as num?)?.toDouble(),
    maxMarks: (json['maxMarks'] as num? ?? json['totalMarks'] as num? ?? 10.0)
        .toDouble(),
    feedback: json['feedback'] ?? json['teacherFeedback'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'assignmentId': assignmentId,
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'subjectId': subjectId,
    'fileUrl': fileUrl,
    'submittedAt': submittedAt.toIso8601String(),
    'status': status.name,
    'marksObtained': marksObtained,
    'maxMarks': maxMarks,
    'feedback': feedback,
  };

  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? studentName,
    String? classId,
    String? subjectId,
    String? fileUrl,
    DateTime? submittedAt,
    SubmissionStatus? status,
    double? marksObtained,
    double? maxMarks,
    String? feedback,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      fileUrl: fileUrl ?? this.fileUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      marksObtained: marksObtained ?? this.marksObtained,
      maxMarks: maxMarks ?? this.maxMarks,
      feedback: feedback ?? this.feedback,
    );
  }
}
