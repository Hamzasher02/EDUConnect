import 'package:get/get.dart';
import '../../../services/public_ranking_service.dart';
import '../../../data/models/school_ranking_model.dart';
import '../../../data/enums/app_enums.dart';

class PublicRankingController extends GetxController {
  final PublicRankingService _rankingService = Get.find<PublicRankingService>();

  final RxList<SchoolRankingModel> allSchools = <SchoolRankingModel>[].obs;
  final RxList<SchoolRankingModel> filteredSchools = <SchoolRankingModel>[].obs;
  final RxList<SchoolRankingModel> excellentSchools =
      <SchoolRankingModel>[].obs;
  final RxList<SchoolRankingModel> goodSchools = <SchoolRankingModel>[].obs;
  final RxList<SchoolRankingModel> improvingSchools =
      <SchoolRankingModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  final Rx<SchoolCategory?> selectedFilterCategory = Rx<SchoolCategory?>(null);

  void toggleCategoryFilter(SchoolCategory category) {
    if (selectedFilterCategory.value == category) {
      selectedFilterCategory.value = null; // deselect
    } else {
      selectedFilterCategory.value = category;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Automatically re-load when service list updates
    ever(_rankingService.rankings, (_) => loadRankings());
    loadRankings();
  }

  Future<void> loadRankings() async {
    isLoading.value = true;
    try {
      final all = await _rankingService.getVisibleSchools();
      allSchools.assignAll(all);
      filteredSchools.assignAll(all);

      final grouped = await _rankingService.getSchoolsGroupedByCategory();
      excellentSchools.assignAll(grouped[SchoolCategory.excellent] ?? []);
      goodSchools.assignAll(grouped[SchoolCategory.good] ?? []);
      improvingSchools.assignAll(grouped[SchoolCategory.improving] ?? []);
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSchools.assignAll(allSchools);
      return;
    }

    final results = await _rankingService.searchSchools(query);
    filteredSchools.assignAll(results);
  }
}
