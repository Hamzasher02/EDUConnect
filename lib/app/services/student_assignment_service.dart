import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../data/models/submission_model.dart' as global;
import '../modules/student/models/assignment_models.dart' as local_assignment;
import '../data/enums/app_enums.dart';

class StudentAssignmentService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
  }

  Future<List<local_assignment.StudentAssignmentViewModel>>
  getAssignmentsForStudent(String studentId, String classNumber) async {
    _validateSession();

    final schoolId = _authService.session.value?.schoolId ?? '';
    final allAssignments = _schoolDataService.getAssignments(schoolId);

    // 1. Fetch Student profile to get their specific assigned subjects

    // FIX: Removing undefined getter assignedSubjectIds. This property does not exist in StudentModel.
    // If student subjects are needed, they should be fetched from the class or another mapping.
    // Assuming for now students are assigned to all subjects in their class.
    final studentSubjectIds = <String>[];

    // Helper to normalize class names for comparison
    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();
    final targetClass = normalize(classNumber);

    final classAssignments = allAssignments.where((a) {
      final classMatch = normalize(a.classNumber) == targetClass;
      if (!classMatch) return false;

      // Strict check: Is the student assigned to this specific subject?
      final classSubjects = _schoolDataService
          .getSubjectsBySchool(schoolId)
          .where((s) => normalize(s.classId) == targetClass);

      final currentSubject = classSubjects.firstWhereOrNull(
        (s) => s.name == a.subjectName,
      );

      if (currentSubject != null && studentSubjectIds.isNotEmpty) {
        return studentSubjectIds.contains(currentSubject.id);
      }

      return true;
    }).toList();

    final studentSubmissions =
        _schoolDataService.submissions[schoolId] ?? <global.SubmissionModel>[];
    final mySubmissions = studentSubmissions
        .where((s) => s.studentId == studentId)
        .toList();

    final List<local_assignment.StudentAssignmentViewModel> viewModels =
        classAssignments.map((asn) {
          final submission = mySubmissions.firstWhereOrNull(
            (s) => s.assignmentId == asn.id,
          );

          final studentAsn = local_assignment.StudentAssignmentModel(
            id: asn.id,
            classId: asn.classNumber,
            subject: asn.subjectName,
            title: asn.title,
            description: asn.description,
            assignedDate: DateTime.now().subtract(
              const Duration(days: 7),
            ), // Ideally from Firebase
            dueDate: asn.dueDate,
            createdBy: asn.teacherId,
          );

          return local_assignment.StudentAssignmentViewModel(
            assignment: studentAsn,
            submission: submission != null
                ? local_assignment.AssignmentSubmissionModel(
                    studentId: submission.studentId,
                    assignmentId: submission.assignmentId,
                    status: _mapSubmissionStatus(submission.status),
                    submittedAt: submission.submittedAt,
                    submittedFileUrl: submission.fileUrl,
                    marksObtained: submission.marksObtained,
                    teacherFeedback: submission.feedback,
                  )
                : null,
          );
        }).toList();

    viewModels.sort((a, b) {
      final statusA = a.calculatedStatus;
      final statusB = b.calculatedStatus;

      if (statusA == local_assignment.SubmissionStatus.late &&
          statusB != local_assignment.SubmissionStatus.late) {
        return -1;
      }
      if (statusA != local_assignment.SubmissionStatus.late &&
          statusB == local_assignment.SubmissionStatus.late) {
        return 1;
      }

      return a.assignment.dueDate.compareTo(b.assignment.dueDate);
    });

    return viewModels;
  }

  local_assignment.SubmissionStatus _mapSubmissionStatus(dynamic status) {
    if (status is global.SubmissionStatus) {
      return status == global.SubmissionStatus.graded
          ? local_assignment.SubmissionStatus.graded
          : local_assignment.SubmissionStatus.submitted;
    }
    if (status is String) {
      return local_assignment.SubmissionStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => local_assignment.SubmissionStatus.submitted,
      );
    }
    return local_assignment.SubmissionStatus.submitted;
  }

  Future<void> submitAssignment(global.SubmissionModel submission) async {
    _validateSession();
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    await _schoolDataService.submitAssignment(session.schoolId!, submission);
  }
}
