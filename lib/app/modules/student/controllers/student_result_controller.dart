import 'package:get/get.dart';
import '../models/result_models.dart';
import '../../../services/student_result_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentResultController extends GetxController {
  final _service = Get.find<StudentResultService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final examSummaries = <ExamSummaryModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  final selectedExam = Rxn<ExamSummaryModel>();

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);

    // React to live changes in marks data
    ever(_schoolDataService.results, (_) => loadResults());
    ever(_schoolDataService.academicResults, (_) => loadResults());

    loadResults();
  }

  Future<void> loadResults() async {
    try {
      isLoading.value = true;
      final data = await _service.getAllExamSummaries(_studentId);
      examSummaries.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshResults() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot refresh while offline');
      return;
    }
    await loadResults();
  }

  void selectExam(ExamSummaryModel summary) {
    selectedExam.value = summary;
  }
}
