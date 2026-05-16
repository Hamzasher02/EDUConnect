class SubjectModel {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;

  SubjectModel({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      classId: json['classId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class TeacherAssignmentModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String classId;
  final String classNumber;
  final String subjectId;
  final String subjectName;
  final DateTime assignedAt;

  TeacherAssignmentModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.classNumber,
    required this.subjectId,
    required this.subjectName,
    required this.assignedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'classId': classId,
    'classNumber': classNumber,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'assignedAt': assignedAt.toIso8601String(),
  };

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentModel(
      id: json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      classId: json['classId'] ?? '',
      classNumber: json['classNumber'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : DateTime.now(),
    );
  }
}
