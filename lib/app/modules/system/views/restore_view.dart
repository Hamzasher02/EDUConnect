import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../controllers/system_controller.dart';

class RestoreView extends GetView<SystemController> {
  const RestoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'System Restore',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 50,
            right: 50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  // ignore: deprecated_member_use
color: Colors.redAccent.withValues(alpha: 0.1),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Restoring data will overwrite existing records. Ensure you have a recent backup before proceeding.',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildRestoreOption(
                  'Full System Restore',
                  'Restore the entire database from a selected backup file.',
                  Icons.settings_backup_restore,
                  () => controller.restoreSystem('Full System'),
                ),
                const SizedBox(height: 16),
                _buildRestoreOption(
                  'Single School Restore',
                  'Restore data for a specific school only.',
                  Icons.school,
                  () => controller.restoreSystem('Single School'),
                ),
                const SizedBox(height: 16),
                _buildRestoreOption(
                  'Module-based Restore',
                  'Restore specific modules (Students, Fees, etc.)',
                  Icons.view_module,
                  () => controller.restoreSystem('Module Based'),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Restore Request History',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    if (controller.restoreRequests.isEmpty) {
                      return const Center(
                        child: Text(
                          'No restore requests yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.restoreRequests.length,
                      itemBuilder: (context, index) {
                        final req = controller.restoreRequests[index];
                        return ListTile(
                          title: Text(
                            req.scope,
                            style: const TextStyle(color: AppColors.white),
                          ),
                          subtitle: Text(
                            'Status: ${req.status}',
                            style: TextStyle(
                              color: req.status == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          trailing: Text(
                            '${req.timestamp.day}/${req.timestamp.month} ${req.timestamp.hour}:${req.timestamp.minute}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreOption(
    String title,
    String desc,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GlassContainer(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(desc, style: const TextStyle(color: Colors.white54)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}


