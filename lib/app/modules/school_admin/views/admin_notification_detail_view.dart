import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../controllers/school_admin_controller.dart';
import '../../../data/enums/app_enums.dart';

class AdminNotificationDetailView extends GetView<SchoolAdminController> {
  const AdminNotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Details', style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final n = controller.selectedNotification.value;

        if (n == null) {
          return const Center(
            child: Text(
              'No notification selected',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return SingleChildScrollView(
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
                        color: _getTypeColor(n.type).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getTypeColor(n.type).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        n.type.name.toUpperCase(),
                        style: TextStyle(
                          color: _getTypeColor(n.type),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(n.timestamp),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  n.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'From: ',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    Text(
                      'School System',
                      style: TextStyle(
                        color: AppColors.accentLime,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40, color: Colors.white10),
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
                    text: 'Back to Inbox',
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.fee:
        return Colors.orangeAccent;
      case NotificationType.exam:
        return Colors.cyanAccent;
      case NotificationType.attendance:
        return Colors.lightGreenAccent;
      case NotificationType.system:
        return Colors.redAccent;
      case NotificationType.announcement:
        return AppColors.accentLime;
      default:
        return Colors.white54;
    }
  }
}
