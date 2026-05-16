import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/teacher_dashboard_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/messaging/notification_model.dart';
import '../../../data/enums/app_enums.dart'; // For NotificationType

class TeacherNotificationsView extends GetView<TeacherDashboardController> {
  const TeacherNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          // Test notification button
          IconButton(
            icon: const Icon(Icons.add_alert, color: AppColors.accentLime),
            onPressed: controller.simulateNewNotification,
            tooltip: 'Add Test Notification',
          ),
        ],
      ),
      body: Obx(() {
        // Access recentNotifications instead of notifications
        if (controller.recentNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 80, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create a test notification',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          );
        }

        // Sort: unread first, then by timestamp desc
        final sortedNotifications = controller.recentNotifications.toList()
          ..sort((a, b) {
            if (a.isRead != b.isRead) {
              return a.isRead ? 1 : -1; // Unread first
            }
            return b.timestamp.compareTo(a.timestamp); // Newest first
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedNotifications.length,
          itemBuilder: (context, index) {
            final notification = sortedNotifications[index];
            return _buildNotificationCard(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final timeAgo = _formatTimeAgo(notification.timestamp);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.accentLime,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check, color: AppColors.primaryBlack),
      ),
      onDismissed: (_) {
        controller.markNotificationRead(notification.id);
      },
      child: Card(
        color: isUnread
            ? AppColors.cardDark
            : AppColors.cardDark.withValues(alpha: 0.5),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isUnread
              ? BorderSide(color: AppColors.accentLime, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isUnread
              ? () => controller.markNotificationRead(notification.id)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type icon
                    _getTypeIcon(notification.type),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Unread indicator
                    if (isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.accentLime,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Message
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Timestamp
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTypeIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.announcement:
        icon = Icons.campaign;
        color = Colors.purple;
        break;
      case NotificationType.alert:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case NotificationType.exam:
        icon = Icons.school;
        color = Colors.blue;
        break;
      case NotificationType.system:
        icon = Icons.settings;
        color = AppColors.accentLime;
        break;
      case NotificationType.fee:
        icon = Icons.attach_money;
        color = Colors.red;
        break;
      case NotificationType.attendance:
        icon = Icons.calendar_today;
        color = Colors.teal;
        break;
      // Default fallback
      default:
        icon = Icons.notifications;
        color = AppColors.accentLime;
    }

    return Icon(icon, color: color, size: 24);
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
