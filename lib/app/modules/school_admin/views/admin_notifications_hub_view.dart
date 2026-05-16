import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../controllers/school_admin_controller.dart';

class AdminNotificationsHubView extends GetView<SchoolAdminController> {
  const AdminNotificationsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications Hub',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHubTile(
              title: 'Create Notification',
              subtitle: 'Send new announcements or alerts',
              icon: Icons.add_circle_outline,
              color: AppColors.accentLime,
              onTap: controller.openCreateNotification,
            ),
            const SizedBox(height: 20),
            _buildHubTile(
              title: 'Sent History',
              subtitle: 'View and manage sent notifications',
              icon: Icons.history,
              color: Colors.cyanAccent,
              onTap: controller.openSentNotifications,
            ),
            const SizedBox(height: 20),
            _buildHubTile(
              title: 'Drafts',
              subtitle: 'Coming soon: Saved notifications',
              icon: Icons.edit_note,
              color: Colors.orangeAccent,
              onTap: () =>
                  Get.snackbar('Info', 'Drafts feature is coming soon!'),
              isDisabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDisabled ? Colors.white38 : AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (!isDisabled)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
