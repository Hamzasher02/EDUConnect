import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/school_card.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.accentLime.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Super Admin Panel',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Overview',
                                    style: TextStyle(color: Colors.white54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Obx(
                                  () => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Get.toNamed(
                                            AppRoutes.superAdminNotifications,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.notifications,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      if (controller.unreadNotificationCount.value >
                                          0)
                                        Positioned(
                                          top: 10,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              '${controller.unreadNotificationCount.value}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      controller.recalculateSchoolRankings(),
                                  icon: const Icon(
                                    Icons.auto_graph_rounded,
                                    color: AppColors.accentLime,
                                    size: 20,
                                  ),
                                  tooltip: 'Recalculate Rankings',
                                ),
                                IconButton(
                                  onPressed: () {
                                    debugPrint(
                                      'Attempting to navigate to Profile: ${AppRoutes.profile}',
                                    );
                                    if (AppRoutes.profile.isEmpty) {
                                      debugPrint(
                                        'Error: AppRoutes.profile is empty!',
                                      );
                                    } else {
                                      Get.toNamed(AppRoutes.profile);
                                    }
                                  },
                                  icon: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.accentLime,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.logout(),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  tooltip: 'Logout',
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.settings,
                                color: AppColors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'backup') {
                                  Get.toNamed(AppRoutes.backup);
                                } else if (value == 'restore') {
                                  Get.toNamed(AppRoutes.restore);
                                } else if (value == 'audit') {
                                  Get.toNamed(AppRoutes.auditLogs);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'backup',
                                      child: Row(
                                        children: [
                                          Icon(Icons.backup, color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('System Backup'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'restore',
                                      child: Row(
                                        children: [
                                          Icon(Icons.restore, color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('System Restore'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'audit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.history, color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('Audit Logs'),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Metrics
                        Row(
                          children: [
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Subscription',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Text(
                                        'PKR ${controller.totalSubscription.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppColors.accentLime,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Students',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Text(
                                        '${controller.totalStudents}',
                                        style: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Schools',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Text(
                                        '${controller.totalSchools}',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Teachers',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Text(
                                        '${controller.totalTeachers}',
                                        style: const TextStyle(
                                          color: Colors.purpleAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Actions & Search
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: controller.searchController,
                                    onChanged: controller.filterSchools,
                                    onTap: () => controller.isSearching.value = true,
                                    onSubmitted: (v) =>
                                        controller.isSearching.value = false,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search for your school...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.white54,
                                      ),
                                      suffixIcon: controller.searchQuery.value.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white54,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                controller.searchController.clear();
                                                controller.filterSchools('');
                                                controller.isSearching.value = false;
                                              },
                                            )
                                          : null,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (!controller.isSearching.value) ...[
                                const SizedBox(width: 16),
                                GlassButton(
                                  text: '+ Register New School',
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.registerSchool);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Registered Schools',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final school = controller.filteredSchools[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SchoolCard(
                              school: school,
                              unreadMessages: controller.getUnreadMessageCount(
                                school.id,
                              ),
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.schoolDetail,
                                  arguments: school,
                                );
                              },
                            ),
                          );
                        },
                        childCount: controller.filteredSchools.length,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
