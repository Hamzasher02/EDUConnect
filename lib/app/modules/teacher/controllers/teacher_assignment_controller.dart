import 'package:get/get.dart';
import '../models/teacher_models.dart';
import '../services/teacher_dashboard_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../data/models/submission_model.dart' as global_submission;

class TeacherAssignmentController extends GetxController {
  final _dashboardService = Get.find<TeacherDashboardService>();

  final filteredAssignments = <AssignmentModel>[].obs;
  final currentSubmissions = <global_submission.SubmissionModel>[].obs;
  final selectedAssignmentId = ''.obs;
  final isLoading = false.obs;

  // Assigned Classes and Subjects from Timetable
  final assignedClasses = <String>[].obs;
  final assignedSubjects = <String>[].obs;

  // Selection state for dropdowns
  final selectedClass = ''.obs;
  final selectedSubject = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to timetable changes to update dropdowns reactively
    ever(_dashboardService.teacherTimetable, (_) => _loadAssignedData());

    // Listen to submission changes for real-time updates
    _setupSubmissionListener();

    _loadAssignedData();
    // Default filter for current teacher's assignments
    filterAssignments();
  }

  void _setupSubmissionListener() {
    final schoolDataService = Get.find<SchoolDataService>();

    // Refresh submissions whenever the source map changes OR a different assignment is selected
    everAll([schoolDataService.submissions, selectedAssignmentId], (_) {
      if (selectedAssignmentId.isNotEmpty) {
        _refreshSubmissionsSync();
      }
    });
  }

  void _refreshSubmissionsSync() {
    final authService = Get.find<AuthService>();
    final schoolDataService = Get.find<SchoolDataService>();
    final session = authService.session.value;
    final schoolId = session?.schoolId;
    if (schoolId == null) return;

    // Strict Cross-Reference: Verify assignment belongs to this teacher/class/subject context
    final assignmentId = selectedAssignmentId.value;
    final assignmentsList = schoolDataService.getAssignmentsBySchool(schoolId);
    final asn = assignmentsList.firstWhereOrNull((a) => a.id == assignmentId);

    if (asn == null) return; // Not found

    // Security Check: Does the teacher match and is the class/subject context correct?
    final teacherMatch = asn.teacherId == session?.userId;
    // Note: selectedClass/Subject might be empty if we just entered via a direct link,
    // but typically they are set via dropdowns or onInit.
    // If we want total strictness:
    final contextMatch =
        (selectedClass.isEmpty || asn.classNumber == selectedClass.value) &&
        (selectedSubject.isEmpty || asn.subjectName == selectedSubject.value);

    if (!teacherMatch || !contextMatch) {
      print(
        'SECURITY: Blocking submission load. Teacher ($teacherMatch) or Context ($contextMatch) mismatch.',
      );
      currentSubmissions.clear();
      return;
    }

    final subms = schoolDataService.getAssignmentSubmissions(
      schoolId,
      assignmentId,
    );
    currentSubmissions.assignAll(subms);
  }

  void _loadAssignedData() {
    print('DEBUG: TeacherAssignmentController - Loading Assigned Data');
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    // 1. Extract classes from Timetable
    final Set<String> classes = timetable.map((s) => s.classNumber).toSet();

    // 2. Add classes from Admin Assignments (getAssignedClasses)
    classes.addAll(assigned.map((a) => a.classNumber));

    final classList = classes.toList();
    classList.sort();

    print('DEBUG: Assigned Classes Found: $classList');
    assignedClasses.assignAll(classList);

    // If we only have one class, auto-select it
    if (classList.length == 1 && selectedClass.isEmpty) {
      onClassSelected(classList.first);
    }
  }

  void onClassSelected(String classNumber) {
    print('DEBUG: Class Selected: $classNumber');
    selectedClass.value = classNumber;
    selectedSubject.value = ''; // Reset subject selection

    // Filter subjects for this specific class from both sources
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    final Set<String> subjects = timetable
        .where((s) => s.classNumber == classNumber)
        .map((s) => s.subjectName)
        .toSet();

    subjects.addAll(
      assigned
          .where((a) => a.classNumber == classNumber)
          .map((a) => a.subjectName),
    );

    final subjectList = subjects.toList();
    subjectList.sort();

    print('DEBUG: Subjects Found for $classNumber: $subjectList');
    assignedSubjects.assignAll(subjectList);

    // If we only have one subject, auto-select it
    if (subjectList.length == 1) {
      selectedSubject.value = subjectList.first;
    }
  }

  void filterAssignments({String? classId, bool? completed}) {
    filteredAssignments.assignAll(
      _dashboardService.filterAssignments(
        classId: classId,
        completed: completed,
      ),
    );
  }

  Future<void> createAssignment(AssignmentModel assignment) async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final schoolDataService = Get.find<SchoolDataService>();

      final session = authService.session.value;
      if (session == null || session.schoolId == null) {
        throw 'No active session or school';
      }

      final newAssignment = AssignmentModel(
        id: '', // Firestore gen
        title: assignment.title,
        description: assignment.description,
        subjectName: assignment.subjectName,
        classNumber: assignment.classNumber,
        teacherId: session.userId,
        dueDate: assignment.dueDate,
        totalStudents: assignment.totalStudents,
        submissionCount: assignment.submissionCount,
        isCompleted: assignment.isCompleted,
        maxMarks: assignment.maxMarks,
      );

      await schoolDataService.addAssignment(session.schoolId!, newAssignment);

      // --- SEND NOTIFICATION TO CLASS ---
      final notification = NotificationModel(
        id: '',
        title: 'New Assignment: ${newAssignment.title}',
        message:
            'A new assignment has been posted for ${newAssignment.subjectName}. Due: ${newAssignment.dueDate.day}/${newAssignment.dueDate.month}',
        timestamp: DateTime.now(),
        type: NotificationType.announcement,
        audience: NotificationAudience.classOnly,
        targetId: newAssignment.classNumber,
        senderId: session.userId,
      );
      await schoolDataService.addNotification(session.schoolId!, notification);

      // Refresh list (optional if using streams, but filteredAssignments is local)
      filterAssignments();

      Get.back(); // Close create view
      Get.snackbar('Success', 'Assignment created successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void loadSubmissions(String assignmentId) {
    selectedAssignmentId.value = assignmentId;
    _refreshSubmissionsSync();
  }

  Future<void> gradeStudentSubmission({
    required String submissionId,
    required double marks,
    required String feedback,
  }) async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final schoolDataService = Get.find<SchoolDataService>();
      final schoolId = authService.session.value?.schoolId;
      if (schoolId == null) throw 'No school ID';

      // Find identifying submission
      final subm = currentSubmissions.firstWhereOrNull(
        (s) => s.id == submissionId,
      );
      if (subm == null) throw 'Submission not found';

      final graded = subm.copyWith(
        marksObtained: marks,
        feedback: feedback,
        status: global_submission.SubmissionStatus.graded,
      );

      // Validate marks against max marks
      if (marks > subm.maxMarks) {
        throw 'Marks cannot exceed Max Marks (${subm.maxMarks})';
      }

      await schoolDataService.gradeSubmission(schoolId, graded);

      // --- SEND NOTIFICATION TO STUDENT ---
      final assignmentsList = schoolDataService.getAssignmentsBySchool(
        schoolId,
      );
      final asn = assignmentsList.firstWhereOrNull(
        (a) => a.id == subm.assignmentId,
      );
      final assignmentTitle = asn?.title ?? 'Assignment';

      final notification = NotificationModel(
        id: '',
        title: 'Assignment Graded',
        message:
            'Your assignment "$assignmentTitle" has been graded. Marks: $marks/${subm.maxMarks}',
        timestamp: DateTime.now(),
        type: NotificationType.exam, // Change to exam for grading
        audience: NotificationAudience.specificStudent,
        targetId: subm.studentId,
        senderId: authService.session.value?.userId ?? '',
      );
      await schoolDataService.addNotification(schoolId, notification);

      // Update local list
      final idx = currentSubmissions.indexWhere((s) => s.id == submissionId);
      if (idx != -1) currentSubmissions[idx] = graded;

      Get.snackbar('Success', 'Submission graded successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final schoolDataService = Get.find<SchoolDataService>();
      final schoolId = authService.session.value?.schoolId;
      if (schoolId == null) throw 'No school ID';

      await schoolDataService.deleteAssignment(schoolId, assignmentId);

      // Refresh current filters
      filterAssignments();
      Get.snackbar('Success', 'Assignment removed successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
