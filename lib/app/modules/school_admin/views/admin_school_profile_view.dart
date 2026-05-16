import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class AdminSchoolProfileView extends GetView<SchoolAdminController> {
  const AdminSchoolProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('School Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: Obx(() {
          final schoolName = controller.schoolName.value;
          final category = controller.base.schoolCategory.value;
          final fee = controller.base.subscriptionFee.value;
          final status = controller.base.schoolStatus.value;
          final isVisible = controller.base.isVisibleOnRanking.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.accentLime.withValues(alpha: 0.1),
                        child: const Icon(Icons.school, size: 50, color: AppColors.accentLime),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        schoolName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentLime.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accentLime,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'RANKING & VISIBILITY',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassContainer(
                  padding: const EdgeInsets.all(8),
                  child: SwitchListTile(
                    title: const Text(
                      'Show on Ranking',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'If disabled, your school will be hidden from all public categories and rankings.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    value: isVisible,
                    activeThumbColor: AppColors.accentLime,
                    onChanged: (val) {
                      // Implementation for visibility toggle
                      controller.base.schoolDataService.updateSchoolVisibility(
                        controller.base.currentSchoolId,
                        val,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'SUBSCRIPTION DETAILS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  icon: Icons.payments_outlined,
                  label: 'Subscription Status',
                  value: status.toUpperCase(),
                  valueColor: status == 'active' ? AppColors.accentLime : Colors.orangeAccent,
                ),
                _buildDetailItem(
                  icon: Icons.money,
                  label: 'Monthly Fee',
                  value: '₹${fee.toStringAsFixed(1)}',
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'STATISTICS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Students',
                        value: controller.base.schoolDataService.getStudentsBySchool(controller.base.currentSchoolId).length.toString(),
                        icon: Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Teachers',
                        value: controller.base.schoolDataService.getTeachersBySchool(controller.base.currentSchoolId).length.toString(),
                        icon: Icons.school_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentLime),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
