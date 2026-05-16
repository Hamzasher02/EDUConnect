import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../../../services/student_exam_service.dart';
import '../../../services/school_data_service.dart';
import '../../../services/auth_service.dart';

class StudentExamController extends GetxController {
  final _service = Get.find<StudentExamService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final exams = <StudentExamModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);

    // Initial load and setup reactive listeners
    _setupDataListeners();
  }

  void _setupDataListeners() {
    // 1. Listen to Session changes
    ever(_authService.session, (_) => loadExamSchedule());

    // 2. Listen to the global exams map (when new school data loads)
    ever(_schoolDataService.exams, (_) => loadExamSchedule());

    // 3. Also listen to the specific school's exam list for real-time updates
    ever(_authService.session, (_) {
      final schoolId = _authService.session.value?.schoolId;
      if (schoolId != null) {
        final examsList = _schoolDataService.exams[schoolId];
        if (examsList != null) {
          ever(examsList, (_) => loadExamSchedule());
        }
      }
    });

    // 4. Listen to the global students map (we need student's classNumber)
    ever(_schoolDataService.students, (_) => loadExamSchedule());

    // Initial trigger
    loadExamSchedule();
  }

  Future<void> loadExamSchedule() async {
    final session = _authService.session.value;
    if (session == null) {
      print('StudentExamController: No active session found');
      return;
    }

    try {
      print(
        'StudentExamController: Loading exams for student ${session.userId}',
      );
      // Don't show loading on every reactive update to avoid flicker
      if (exams.isEmpty) isLoading.value = true;

      final data = await _service.fetchExamSchedule(session.userId);
      print(
        'StudentExamController: Received ${data.length} exams from service',
      );

      exams.assignAll(data);
      print('StudentExamController: Successfully updated exam list');
    } catch (e, stack) {
      print('StudentExamController: Error loading exams: $e');
      print(stack);
      // Optional: Get.snackbar('Error', 'Failed to load exam schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentExamModel> getExamsForDate(DateTime date) {
    return exams
        .where(
          (e) =>
              e.examDate.year == date.year &&
              e.examDate.month == date.month &&
              e.examDate.day == date.day,
        )
        .toList();
  }
}
