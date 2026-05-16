import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';

class AdminNotificationsView extends GetView<SchoolAdminController> {
  const AdminNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.accentLime),
              onPressed: controller.isOffline.value
                  ? () => controller.markAllNotificationsAsRead()
                  : controller.markAllNotificationsAsRead,
              tooltip: 'Mark all as read',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner
          Obx(() {
            if (!controller.isOffline.value) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              // ignore: deprecated_member_use
              color: Colors.orange.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Text(
                'Offline: Viewing cached notifications',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          }),

          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => controller.updateNotificationSearchQuery(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                // ignore: deprecated_member_use
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                // ignore: deprecated_member_use
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              final notifications = controller.filteredNotifications;
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.notificationSearchQuery.value.isEmpty
                            ? 'No notifications'
                            : 'No search results',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return _buildNotificationCard(n);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n) {
    return GestureDetector(
      onTap: () => controller.openNotification(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator
              if (!n.isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.accentLime,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTypeLabel(n.type),
                          style: TextStyle(
                            color: _getTypeColor(n.type),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, h:mm a').format(n.timestamp),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.title,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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

  String _getTypeLabel(NotificationType type) {
    return type.name.toUpperCase();
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
