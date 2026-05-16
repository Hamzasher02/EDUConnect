import '../enums/app_enums.dart';

class ResultAuditLog {
  final String teacherId;
  final DateTime timestamp;
  final double previousValue;
  final double newValue;

  ResultAuditLog({
    required this.teacherId,
    required this.timestamp,
    required this.previousValue,
    required this.newValue,
  });

  Map<String, dynamic> toJson() => {
    'teacherId': teacherId,
    'timestamp': timestamp.toIso8601String(),
    'previousValue': previousValue,
    'newValue': newValue,
  };

  factory ResultAuditLog.fromJson(Map<String, dynamic> json) => ResultAuditLog(
    teacherId: json['teacherId'] ?? '',
    timestamp: DateTime.parse(
      json['timestamp'] ?? DateTime.now().toIso8601String(),
    ),
    previousValue: (json['previousValue'] as num? ?? 0).toDouble(),
    newValue: (json['newValue'] as num? ?? 0).toDouble(),
  );
}

class AcademicResultModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String subjectId;
  final String teacherId;
  final String assessmentId;
  final String assessmentName;
  final AssessmentCategory category;
  final double marksObtained;
  final double maxMarks;
  final DateTime updatedAt;
  final List<ResultAuditLog> history;

  AcademicResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.assessmentId,
    required this.assessmentName,
    required this.category,
    required this.marksObtained,
    required this.maxMarks,
    required this.updatedAt,
    this.history = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'assessmentId': assessmentId,
    'assessmentName': assessmentName,
    'category': category.name,
    'marksObtained': marksObtained,
    'maxMarks': maxMarks,
    'updatedAt': updatedAt.toIso8601String(),
    'history': history.map((e) => e.toJson()).toList(),
  };

  factory AcademicResultModel.fromJson(Map<String, dynamic> json) =>
      AcademicResultModel(
        id: json['id'] ?? '',
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        classId: json['classId'] ?? '',
        subjectId: json['subjectId'] ?? '',
        teacherId: json['teacherId'] ?? '',
        assessmentId: json['assessmentId'] ?? '',
        assessmentName: json['assessmentName'] ?? '',
        category: AssessmentCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => AssessmentCategory.custom,
        ),
        marksObtained: (json['marksObtained'] as num? ?? 0).toDouble(),
        maxMarks: (json['maxMarks'] as num? ?? 100).toDouble(),
        updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
        history: (json['history'] as List? ?? [])
            .map((e) => ResultAuditLog.fromJson(e))
            .toList(),
      );

  AcademicResultModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? classId,
    String? subjectId,
    String? teacherId,
    String? assessmentId,
    String? assessmentName,
    AssessmentCategory? category,
    double? marksObtained,
    double? maxMarks,
    DateTime? updatedAt,
    List<ResultAuditLog>? history,
  }) {
    return AcademicResultModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      assessmentId: assessmentId ?? this.assessmentId,
      assessmentName: assessmentName ?? this.assessmentName,
      category: category ?? this.category,
      marksObtained: marksObtained ?? this.marksObtained,
      maxMarks: maxMarks ?? this.maxMarks,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? this.history,
    );
  }
}

class ResultMatrixColumn {
  final String id;
  final String name;
  final AssessmentCategory category;
  final double maxMarks;

  ResultMatrixColumn({
    required this.id,
    required this.name,
    required this.category,
    required this.maxMarks,
  });
}

class ResultMatrixModel {
  final List<ResultMatrixColumn> columns;
  final List<StudentResultRow> rows;

  ResultMatrixModel({required this.columns, required this.rows});
}

class StudentResultRow {
  final String studentId;
  final String studentName;
  final Map<String, AcademicResultModel> results; // assessmentId -> Result

  StudentResultRow({
    required this.studentId,
    required this.studentName,
    required this.results,
  });

  double get totalObtained =>
      results.values.fold(0, (sum, r) => sum + r.marksObtained);
  double get totalMax => results.values.fold(0, (sum, r) => sum + r.maxMarks);
  double get percentage => totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }
}
