import 'package:get/get.dart';
import '../models/assignment_models.dart';
import '../../../data/models/submission_model.dart' as global;
import '../../../services/student_assignment_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentAssignmentController extends GetxController {
  final _service = Get.find<StudentAssignmentService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final assignments = <StudentAssignmentViewModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  final selectedAssignment = Rxn<StudentAssignmentViewModel>();

  String get _studentId => _authService.session.value?.userId ?? '';
  // Assuming class number '9' for demo
  String get _classNumber => '9';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);
    loadAssignments();
  }

  Future<void> loadAssignments() async {
    try {
      isLoading.value = true;
      final data = await _service.getAssignmentsForStudent(
        _studentId,
        _classNumber,
      );
      assignments.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAssignments() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot refresh while offline');
      return;
    }
    await loadAssignments();
  }

  Future<void> submitAssignment(String assignmentId, String fileUrl) async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot submit while offline');
      return;
    }

    try {
      isLoading.value = true;
      final submission = global.SubmissionModel(
        id: '', // Generated later
        assignmentId: assignmentId,
        studentId: _studentId,
        studentName: 'Student', // Can fetch if needed
        classId: _classNumber,
        subjectId: '', // Ideally from assignment
        submittedAt: DateTime.now(),
        fileUrl: fileUrl,
        status: global.SubmissionStatus.submitted,
        maxMarks: 10.0, // Default or ignored
      );
      await _service.submitAssignment(submission);
      Get.snackbar('Success', 'Assignment submitted successfully');
      await loadAssignments(); // Reload to update status

      // Update the selected assignment ViewModel if open
      if (selectedAssignment.value?.assignment.id == assignmentId) {
        selectedAssignment.value = assignments.firstWhere(
          (a) => a.assignment.id == assignmentId,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Submission failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAssignment(StudentAssignmentViewModel vm) {
    selectedAssignment.value = vm;
  }

  Future<String?> pickAndUploadFile(String assignmentId) async {
    // In a real app, use file_picker or image_picker and firebase_storage.
    // For this mock implementation, we return a mock URL after a delay.
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      return 'https://example.com/mock_file_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
