import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../controllers/school_controller.dart';
import '../../../routes/app_routes.dart';

class SchoolDetailView extends GetView<SchoolController> {
  const SchoolDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the school from arguments if not already set (e.g. passed via Get.toNamed)
    // For now we assume controller.selectedSchool is set by the previous screen or arguments.
    // Ideally use Get.arguments
    if (Get.arguments != null) {
      controller.selectedSchool.value = Get.arguments;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'School Details',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final school = controller.selectedSchool.value;
        if (school == null) {
          return const Center(
            child: Text(
              'No school selected',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            school.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            school.address,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      controller.selectedSchool.value?.status
                                              .toLowerCase() ==
                                          'active'
                                      ? AppColors.accentLime
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  school.status,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  school.adminEmail,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Section
              const Text(
                'Statistics',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Students',
                      '${school.studentCount}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Teachers',
                      '${school.teacherCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Subscription',
                      'PKR ${school.subscriptionFee.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Ranking', '${school.rankingScore}'),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Actions',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Send Message',
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.message,
                          arguments: school.id,
                          parameters: {'schoolName': school.name},
                        );
                      },
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassButton(
                      text: 'Remove',
                      onPressed: controller.removeSchool,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status toggles (Super Admin Only)
              const Text(
                'Change Status',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusButton('Active'),
                  _buildStatusButton('Pending'),
                  _buildStatusButton('Restricted'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accentLime,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    return TextButton(
      onPressed: () => controller.updateStatus(status),
      child: Text(
        status,
        style: TextStyle(
          color: controller.selectedSchool.value?.status.toLowerCase() ==
                  status.toLowerCase()
              ? AppColors.accentLime
              : Colors.white54,
        ),
      ),
    );
  }
}
