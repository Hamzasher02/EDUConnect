enum SubmissionStatus { notSubmitted, submitted, graded, late }

class StudentAssignmentModel {
  final String id;
  final String classId;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String? attachmentUrl;
  final String createdBy; // teacherId

  StudentAssignmentModel({
    required this.id,
    required this.classId,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    this.attachmentUrl,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'subject': subject,
    'title': title,
    'description': description,
    'assignedDate': assignedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'attachmentUrl': attachmentUrl,
    'createdBy': createdBy,
  };

  factory StudentAssignmentModel.fromJson(Map<String, dynamic> json) {
    return StudentAssignmentModel(
      id: json['id'],
      classId: json['classId'],
      subject: json['subject'],
      title: json['title'],
      description: json['description'],
      assignedDate: DateTime.parse(json['assignedDate']),
      dueDate: DateTime.parse(json['dueDate']),
      attachmentUrl: json['attachmentUrl'],
      createdBy: json['createdBy'],
    );
  }
}

class AssignmentSubmissionModel {
  final String studentId;
  final String assignmentId;
  final SubmissionStatus status;
  final DateTime? submittedAt;
  final String? submittedFileUrl;

  final double? marksObtained;
  final String? teacherFeedback;

  AssignmentSubmissionModel({
    required this.studentId,
    required this.assignmentId,
    required this.status,
    this.submittedAt,
    this.submittedFileUrl,
    this.marksObtained,
    this.teacherFeedback,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'assignmentId': assignmentId,
    'status': status.name,
    'submittedAt': submittedAt?.toIso8601String(),
    'submittedFileUrl': submittedFileUrl,
    'marksObtained': marksObtained,
    'teacherFeedback': teacherFeedback,
  };

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionModel(
      studentId: json['studentId'],
      assignmentId: json['assignmentId'],
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      submittedFileUrl: json['submittedFileUrl'],
      marksObtained: (json['marksObtained'] as num?)?.toDouble(),
      teacherFeedback: json['teacherFeedback'],
    );
  }
}

/// Helper model for UI to combine assignment and student-specific status
class StudentAssignmentViewModel {
  final StudentAssignmentModel assignment;
  final AssignmentSubmissionModel? submission;

  StudentAssignmentViewModel({required this.assignment, this.submission});

  SubmissionStatus get calculatedStatus {
    if (submission?.status == SubmissionStatus.graded) {
      return SubmissionStatus.graded;
    }
    if (submission?.status == SubmissionStatus.submitted) {
      return SubmissionStatus.submitted;
    }

    final now = DateTime.now();
    if (now.isAfter(assignment.dueDate)) return SubmissionStatus.late;

    return SubmissionStatus.notSubmitted;
  }
}
