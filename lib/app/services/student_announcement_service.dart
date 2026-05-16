import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import 'firestore_helper.dart';
import '../modules/student/models/announcement_models.dart' as student_models;
import '../data/enums/app_enums.dart' as enums;

class StudentAnnouncementService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null || session.role != enums.UserRole.student) {
      throw 'Unauthorized access';
    }
  }

  Future<List<student_models.StudentAnnouncementModel>> getAnnouncements(
    String classNumber,
  ) async {
    _validateSession();
    final schoolId = _authService.session.value?.schoolId ?? '';
    final announcements = _schoolDataService.getStudentAnnouncements(
      schoolId,
      classNumber,
    );

    return announcements
        .map(
          (e) => student_models.StudentAnnouncementModel(
            id: e.id,
            title: e.title,
            description: e.message,
            postedBy: e.senderId ?? "School Admin",
            postedDate: e.timestamp,
          ),
        )
        .toList()
      ..sort((a, b) => b.postedDate.compareTo(a.postedDate));
  }

  Future<List<student_models.StudentNotificationModel>> getNotifications(
    String studentId,
  ) async {
    _validateSession();
    final schoolId = _authService.session.value?.schoolId ?? '';
    final notifications = _schoolDataService.getStudentNotifications(
      schoolId,
      studentId,
    );

    return notifications
        .map(
          (e) => student_models.StudentNotificationModel(
            id: e.id,
            type: _mapGlobalToStudentType(e.type),
            title: e.title,
            description: e.message,
            timestamp: e.timestamp,
            isRead: e.isRead,
          ),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  student_models.NotificationType _mapGlobalToStudentType(
    enums.NotificationType type,
  ) {
    switch (type) {
      case enums.NotificationType.fee:
        return student_models.NotificationType.fee;
      case enums.NotificationType.exam:
        return student_models.NotificationType.exam;
      case enums.NotificationType.attendance:
        return student_models.NotificationType.attendance;
      default:
        return student_models.NotificationType.general;
    }
  }

  Future<void> markAsRead(String studentId, String notificationId) async {
    await FirestoreHelper.notifications.doc(notificationId).update({
      'isRead': true,
    });
  }
}
