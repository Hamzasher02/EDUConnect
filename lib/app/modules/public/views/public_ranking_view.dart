import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/public_ranking_controller.dart';
import '../../../data/models/school_ranking_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../routes/app_routes.dart';

class PublicRankingView extends GetView<PublicRankingController> {
  const PublicRankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLime.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.04),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildWelcomeHeader()),
              SliverToBoxAdapter(child: _buildTopFeaturedSection()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: _buildSearchAndFilter()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildRankingGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
      backgroundColor: AppColors.primaryBlack.withValues(alpha: 0.85),
      floating: true,
      pinned: true,
      elevation: 0,
      title: const Text(
        'EDUConnect',
        style: TextStyle(
          color: AppColors.accentLime,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => controller.loadRankings(),
          icon: const Icon(
            Icons.refresh_rounded,
            color: Colors.white70,
            size: 20,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(AppRoutes.login),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentLime, Color(0xFFA8D632)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentLime.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 15, 24, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.accentLime.withValues(alpha: 0.2),
              ),
            ),
            child: const Text(
              'ELITE INSTITUTIONS',
              style: TextStyle(
                color: AppColors.accentLime,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Academic Excellence\nWall of Fame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFeaturedSection() {
    return Obx(() {
      if (controller.allSchools.isEmpty) return const SizedBox.shrink();

      final topThree = controller.allSchools.take(3).toList();
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: topThree.length,
          itemBuilder: (context, index) {
            final school = topThree[index];
            final rank = index + 1;
            Color awardColor = rank == 1
                ? const Color(0xFFFFD700)
                : (rank == 2
                      ? const Color(0xFFC0C0C0)
                      : const Color(0xFFCD7F32));

            return Container(
              width: 150,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    awardColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: awardColor.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: awardColor.withValues(alpha: 0.1),
                      size: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: awardColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: awardColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          school.schoolName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${school.academicPerformanceScore.toInt()}% Performance',
                          style: TextStyle(
                            color: awardColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        _buildRankingCriteriaCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: TextField(
                  onChanged: controller.search,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search institutions...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.accentLime,
                      size: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Excellent',
                SchoolCategory.excellent,
                const Color(0xFFFFD700),
              ),
              const SizedBox(width: 8),
              _buildFilterChip('Good', SchoolCategory.good, Colors.blueAccent),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Improving',
                SchoolCategory.improving,
                Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    SchoolCategory category,
    Color accentColor,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilterCategory.value == category;
      return GestureDetector(
        onTap: () => controller.toggleCategoryFilter(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? accentColor : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRankingCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.accentLime,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Ranking Algorithm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Marks (50%) • Faculty (30%) • Attendance (20%)',
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accentLime,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (controller.allSchools.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: Text(
              'No institutions located.',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        );
      }

      // If searching, show a flattened list
      if (controller.searchQuery.isNotEmpty) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 190,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final school = controller.filteredSchools[index];
              return _buildSchoolCard(school, index + 1);
            }, childCount: controller.filteredSchools.length),
          ),
        );
      }

      final activeFilter = controller.selectedFilterCategory.value;

      return SliverMainAxisGroup(
        slivers: [
          if (controller.excellentSchools.isNotEmpty &&
              (activeFilter == null ||
                  activeFilter == SchoolCategory.excellent)) ...[
            _buildSectionHeader(
              'EXCELLENT INSTITUTIONS (Top Tier)',
              const Color(0xFFFFD700),
            ),
            _buildTierGrid(controller.excellentSchools, 'Excellent'),
          ],
          if (controller.goodSchools.isNotEmpty &&
              (activeFilter == null ||
                  activeFilter == SchoolCategory.good)) ...[
            _buildSectionHeader(
              'GOOD INSTITUTIONS (Established)',
              Colors.blueAccent,
            ),
            _buildTierGrid(controller.goodSchools, 'Good'),
          ],
          if (controller.improvingSchools.isNotEmpty &&
              (activeFilter == null ||
                  activeFilter == SchoolCategory.improving)) ...[
            _buildSectionHeader(
              'IMPROVING (Rising Stars)',
              Colors.orangeAccent,
            ),
            _buildTierGrid(controller.improvingSchools, 'Improving'),
          ],
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierGrid(List<SchoolRankingModel> schools, String tier) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 190,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final school = schools[index];
          return _buildSchoolCard(school, index + 1);
        }, childCount: schools.length),
      ),
    );
  }

  Widget _buildSchoolCard(SchoolRankingModel school, int rank) {
    Color rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2
              ? const Color(0xFFE5E4E2)
              : (rank == 3 ? const Color(0xFFCD7F32) : Colors.white10));

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.publicSchoolDetail, arguments: school),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -5,
                top: -5,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.02),
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252525),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school,
                              color: AppColors.accentLime,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RANK $rank',
                                style: TextStyle(
                                  color: rank <= 3 ? rankColor : Colors.white38,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                school.schoolName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                school.city,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildMetric(
                          Icons.star_rounded,
                          Colors.amber,
                          (school.academicPerformanceScore / 20)
                              .toStringAsFixed(1),
                        ),
                        const SizedBox(width: 10),
                        _buildMetric(
                          Icons.people_alt_rounded,
                          Colors.blueAccent,
                          '${school.totalStudents}',
                        ),
                        const SizedBox(width: 10),
                        _buildMetric(
                          Icons.verified_rounded,
                          AppColors.accentLime,
                          'Live',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.accentLime.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${school.academicPerformanceScore.toInt()}% Performance Score',
                          style: const TextStyle(
                            color: AppColors.accentLime,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
