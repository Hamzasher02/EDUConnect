import 'package:get/get.dart';
import '../models/announcement_models.dart';
import '../../../services/student_announcement_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentAnnouncementsController extends GetxController {
  final _service = Get.find<StudentAnnouncementService>();
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  final announcements = <StudentAnnouncementModel>[].obs;
  final notifications = <StudentNotificationModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;
  final currentTab = 0.obs; // 0 for Announcements, 1 for Notifications

  final studentClassNumber = ''.obs;

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);

    _loadStudentProfile();
  }

  void _loadStudentProfile() {
    final profile = _schoolDataService.getStudentProfile(_studentId);
    if (profile != null) {
      studentClassNumber.value = profile['classNumber'] ?? '';
      loadAll();
    } else {
      once(_schoolDataService.students, (_) => _loadStudentProfile());
    }
  }

  Future<void> loadAll() async {
    if (studentClassNumber.value.isEmpty) return;
    try {
      isLoading.value = true;
      await Future.wait([loadAnnouncements(), loadNotifications()]);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAnnouncements() async {
    announcements.value = await _service.getAnnouncements(
      studentClassNumber.value,
    );
  }

  Future<void> loadNotifications() async {
    notifications.value = await _service.getNotifications(_studentId);
  }

  Future<void> markAsRead(String notificationId) async {
    if (isOffline.value) return;
    try {
      await _service.markAsRead(_studentId, notificationId);
      await loadNotifications();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;
}
