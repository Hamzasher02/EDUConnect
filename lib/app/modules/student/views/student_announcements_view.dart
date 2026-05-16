import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_announcements_controller.dart';
import '../models/announcement_models.dart';
import '../../../widgets/glass_container.dart';

class StudentAnnouncementsView extends GetView<StudentAnnouncementsController> {
  const StudentAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSwitcher(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentLime,
                    ),
                  );
                }
                return controller.currentTab.value == 0
                    ? _buildAnnouncementsList()
                    : _buildNotificationsList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'School Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(
            () => controller.isOffline.value
                ? const Icon(
                    Icons.wifi_off,
                    color: Colors.orangeAccent,
                    size: 20,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildTabItem(0, 'Announcements'),
            _buildTabItem(1, 'Notifications', hasBadge: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, {bool hasBadge = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.currentTab.value = index,
        child: Obx(() {
          final isSelected = controller.currentTab.value == index;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentLime : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white38,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (hasBadge && controller.unreadNotificationsCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${controller.unreadNotificationsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Obx(() {
      if (controller.announcements.isEmpty) {
        return _buildEmptyState('No announcements today');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: controller.announcements.length,
        itemBuilder: (context, index) {
          final ann = controller.announcements[index];
          return _buildAnnouncementCard(ann);
        },
      );
    });
  }

  Widget _buildAnnouncementCard(StudentAnnouncementModel ann) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ann.postedBy,
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(ann.postedDate),
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ann.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ann.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (ann.attachmentUrl != null)
              Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 14,
                    color: AppColors.accentLime,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Document Attached',
                    style: TextStyle(
                      color: AppColors.accentLime.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Get.toNamed('/student-announcement-detail', arguments: ann),
                child: const Text(
                  'Read More',
                  style: TextStyle(color: AppColors.accentLime, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      if (controller.notifications.isEmpty) {
        return _buildEmptyState('Your inbox is clear');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notif = controller.notifications[index];
          return _buildNotificationTile(notif);
        },
      );
    });
  }

  Widget _buildNotificationTile(StudentNotificationModel notif) {
    return GestureDetector(
      onTap: () => controller.markAsRead(notif.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.accentLime.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotifIcon(notif.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: notif.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.description,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('hh:mm a, MMM dd').format(notif.timestamp),
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentLime,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifIcon(NotificationType type) {
    IconData icon;
    Color color;
    switch (type) {
      case NotificationType.assignment:
        icon = Icons.assignment_outlined;
        color = Colors.blueAccent;
        break;
      case NotificationType.exam:
        icon = Icons.quiz_outlined;
        color = Colors.orangeAccent;
        break;
      case NotificationType.fee:
        icon = Icons.payments_outlined;
        color = Colors.greenAccent;
        break;
      case NotificationType.attendance:
        icon = Icons.calendar_today_outlined;
        color = Colors.redAccent;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppColors.accentLime;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.white.withValues(alpha: 0.1),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
