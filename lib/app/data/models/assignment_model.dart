class AssignmentModel {
  String id;
  String title;
  String description;
  String subjectName;
  String classNumber;
  String teacherId;
  DateTime dueDate;
  int totalStudents;
  int submissionCount;
  bool isCompleted;
  double maxMarks;

  AssignmentModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.subjectName,
    required this.classNumber,
    required this.teacherId,
    required this.dueDate,
    this.totalStudents = 0,
    this.submissionCount = 0,
    this.isCompleted = false,
    this.maxMarks = 10.0,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      AssignmentModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        subjectName: json['subjectName'],
        classNumber: json['classNumber'],
        teacherId: json['teacherId'],
        dueDate: DateTime.parse(json['dueDate']),
        totalStudents: json['totalStudents'] ?? 0,
        submissionCount: json['submissionCount'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'subjectName': subjectName,
    'classNumber': classNumber,
    'teacherId': teacherId,
    'dueDate': dueDate.toIso8601String(),
    'totalStudents': totalStudents,
    'submissionCount': submissionCount,
    'isCompleted': isCompleted,
  };
}
