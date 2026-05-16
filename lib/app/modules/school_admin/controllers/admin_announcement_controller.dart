import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../routes/app_routes.dart';

class AdminAnnouncementController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();

  final notifications = <NotificationModel>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    notifications.assignAll(
      base.schoolDataService.getNotificationsForSchool(base.currentSchoolId),
    );
  }

  List<NotificationModel> get notificationsForSchool {
    if (searchQuery.value.isEmpty) return notifications;
    final q = searchQuery.value.toLowerCase();
    return notifications
        .where(
          (n) =>
              n.title.toLowerCase().contains(q) ||
              n.message.toLowerCase().contains(q),
        )
        .toList();
  }

  void updateSearchQuery(String query) => searchQuery.value = query;

  final notifType = NotificationType.announcement.obs;
  final notifAudience = NotificationAudience.wholeSchool.obs;
  final notifTargetClass = ''.obs;
  final notifTargetStudentId = ''.obs;
  final notifTargetTeacherId = ''.obs;
  final notifTitle = ''.obs;
  final notifMessage = ''.obs;

  void openCreateNotification() =>
      Get.toNamed(AppRoutes.adminCreateNotification);
  void openSentNotifications() => Get.toNamed(AppRoutes.adminSentNotifications);

  void openNotification(NotificationModel n) {
    selectedNotification.value = n;
    Get.toNamed(AppRoutes.adminNotificationDetail);
  }

  final selectedNotification = Rxn<NotificationModel>();

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    Get.snackbar('Success', 'All notifications marked as read');
  }

  void sendNotification() {
    if (base.isOffline.value) {
      Get.snackbar('Offline', 'Cannot send notifications while offline.');
      return;
    }
    Get.back();
    Get.snackbar('Success', 'Notification sent successfully');
  }
}
