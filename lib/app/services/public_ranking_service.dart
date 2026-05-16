import 'package:get/get.dart';
import '../data/models/school_ranking_model.dart';
import '../data/enums/app_enums.dart';
import 'firestore_helper.dart';

/// Public Ranking Service - Handles public access to school rankings
/// Filters hidden schools and provides category-based listing
class PublicRankingService extends GetxService {
  final RxList<SchoolRankingModel> rankings = <SchoolRankingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initRankingsStream();
  }

  void _initRankingsStream() {
    rankings.bindStream(
      FirestoreHelper.schools
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map(
            (query) => query.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isVisible = data['isVisibleOnRanking'] ?? true;

                  if (!isVisible) return null;

                  return SchoolRankingModel(
                    schoolId: doc.id,
                    schoolName: data['name'] ?? '',
                    schoolLogoUrl: null,
                    address: data['address'] ?? '',
                    city: data['city'] ?? 'Default City',
                    category: _mapCategory(data['category'] ?? ''),
                    overallScore: (data['rankingScore'] ?? 0.0).toDouble(),
                    academicPerformanceScore: (data['rankingScore'] ?? 0.0)
                        .toDouble(),
                    teacherQualificationScore: 0,
                    attendanceScore: 0,
                    totalTeachers: data['teacherCount'] ?? 0,
                    totalStudents: data['studentCount'] ?? 0,
                    lastCalculatedAt: DateTime.now(),
                  );
                })
                .whereType<SchoolRankingModel>()
                .toList(),
          ),
    );
  }

  SchoolCategory _mapCategory(String cat) {
    if (cat == 'Excellent') return SchoolCategory.excellent;
    if (cat == 'Good') return SchoolCategory.good;
    return SchoolCategory.improving;
  }

  /// Get schools by category (Excellent, Good, Improving)
  Future<List<SchoolRankingModel>> getSchoolsByCategory(
    SchoolCategory category,
  ) async {
    final filtered = rankings.where((r) => r.category == category).toList();
    filtered.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return filtered;
  }

  /// Search schools by name or city
  Future<List<SchoolRankingModel>> searchSchools(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = rankings.where((r) {
      return r.schoolName.toLowerCase().contains(lowerQuery) ||
          r.city.toLowerCase().contains(lowerQuery) ||
          r.address.toLowerCase().contains(lowerQuery);
    }).toList();

    results.sort((a, b) {
      final aExact = a.schoolName.toLowerCase() == lowerQuery;
      final bExact = b.schoolName.toLowerCase() == lowerQuery;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      return b.overallScore.compareTo(a.overallScore);
    });
    return results;
  }

  /// Get public school detail
  Future<SchoolRankingModel?> getPublicSchoolDetail(String schoolId) async {
    return rankings.firstWhereOrNull((r) => r.schoolId == schoolId);
  }

  /// Get all visible schools
  Future<List<SchoolRankingModel>> getVisibleSchools() async {
    final visible = rankings.toList();
    visible.sort((a, b) {
      // Category Priority: Excellent = 0, Good = 1, Improving = 2
      final aPriority = _getCategoryPriority(a.category);
      final bPriority = _getCategoryPriority(b.category);

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return b.overallScore.compareTo(a.overallScore);
    });
    return visible;
  }

  int _getCategoryPriority(SchoolCategory category) {
    switch (category) {
      case SchoolCategory.excellent:
        return 0;
      case SchoolCategory.good:
        return 1;
      case SchoolCategory.improving:
      case SchoolCategory.unrated:
        return 2;
    }
  }

  /// Group schools by category for display
  Future<Map<SchoolCategory, List<SchoolRankingModel>>>
  getSchoolsGroupedByCategory() async {
    final excellent = await getSchoolsByCategory(SchoolCategory.excellent);
    final good = await getSchoolsByCategory(SchoolCategory.good);
    final improving = await getSchoolsByCategory(SchoolCategory.improving);

    return {
      SchoolCategory.excellent: excellent,
      SchoolCategory.good: good,
      SchoolCategory.improving: improving,
    };
  }

  /// Refresh logic (stream handles it usually, but keeping for compatibility)
  Future<void> refreshRankings() async {}
}
