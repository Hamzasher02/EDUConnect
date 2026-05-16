import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';

class NotificationDetailView extends GetView<SchoolAdminController> {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final n = controller.selectedAdminNotification.value;

      if (n == null) {
        return const Scaffold(
          backgroundColor: AppColors.primaryBlack,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Sent Detail',
            style: TextStyle(color: AppColors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _getTypeColor(n.type).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: _getTypeColor(n.type).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        n.typeLabel.toUpperCase(),
                        style: TextStyle(
                          color: _getTypeColor(n.type),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(n.createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  n.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.people_outline,
                  'Audience',
                  n.audienceLabel,
                ),
                if (n.status == NotificationStatus.sent)
                  _buildInfoRow(
                    Icons.check_circle_outline,
                    'Status',
                    'SENT',
                    color: Colors.greenAccent,
                  ),

                const Divider(height: 48, color: Colors.white10),
                const Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  n.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    text: 'Close',
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return AppColors.accentLime;
      case NotificationType.alert:
        return Colors.redAccent;
      case NotificationType.exam:
        return Colors.cyanAccent;
      case NotificationType.fee:
        return Colors.orangeAccent;
      case NotificationType.attendance:
        return Colors.lightGreenAccent;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.message:
        return Colors.blueAccent; // Assuming a color for message type
    }
  }
}
