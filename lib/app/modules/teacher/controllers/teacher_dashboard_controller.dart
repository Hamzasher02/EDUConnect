import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/teacher_dashboard_service.dart';
import '../models/teacher_dashboard_models.dart';
import '../../school_admin/models/school_admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/school_data_service.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/exam_model.dart';

class TeacherDashboardController extends GetxController {
  final _dashboardService = Get.find<TeacherDashboardService>();
  final _authService = Get.find<AuthService>();
  final _storage = GetStorage();
  final _cacheKey = 'teacher_dashboard_cache';

  // --- State ---
  final teacherName = ''.obs;
  final schoolName = ''.obs;
  final rating = 0.0.obs;
  final qualification = ''.obs;
  List<ClassTimetableSlotModel> get todaysClasses => _getClassesForDay(0);
  List<ClassTimetableSlotModel> get upcomingClasses => _getClassesForDay(1);

  List<ClassTimetableSlotModel> _getClassesForDay(int dayOffset) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final targetDate = DateTime.now().add(Duration(days: dayOffset));
    final dayName = days[targetDate.weekday - 1].toLowerCase();
    final dayShort = dayName.substring(0, 3);

    return _dashboardService.teacherTimetable.where((slot) {
      final d = slot.day.trim().toLowerCase();
      return d == dayName || d == dayShort;
    }).toList();
  }

  final recentNotifications = <NotificationModel>[].obs;
  final unreadNotificationCount = 0.obs;
  final unreadMessageCount = 0.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Worker to wait for session on app restart
    ever(_authService.session, (session) {
      if (session != null) {
        // Removed classList.isEmpty and _loadInitialData as they are not part of this controller
        _loadFromCache();
        loadDashboardData();
        _setupUnreadCountListeners();
      }
    });

    if (_authService.session.value != null) {
      _loadFromCache();
      loadDashboardData();
      _setupUnreadCountListeners();
    }
  }

  void _setupUnreadCountListeners() {
    final sId = _authService.session.value?.schoolId ?? '';
    if (sId.isEmpty) return;

    final schoolData = Get.find<SchoolDataService>();

    // Notifications listener
    final notifs = schoolData.notifications[sId];
    if (notifs != null) {
      ever(notifs, (_) => _updateUnreadCounts());
    } else {
      ever(schoolData.notifications, (map) {
        final list = map[sId];
        if (list != null) ever(list, (_) => _updateUnreadCounts());
      });
    }

    // Messages listener
    final msgs = schoolData.messages[sId];
    if (msgs != null) {
      ever(msgs, (_) => _updateUnreadCounts());
    } else {
      ever(schoolData.messages, (map) {
        final list = map[sId];
        if (list != null) ever(list, (_) => _updateUnreadCounts());
      });
    }
  }

  void _loadFromCache() {
    final cached = _storage.read(_cacheKey);
    if (cached != null) {
      try {
        final data = TeacherDashboardData.fromJson(
          Map<String, dynamic>.from(cached),
        );
        teacherName.value = data.teacherName;
        schoolName.value = data.schoolName;
        rating.value = data.rating;
        qualification.value = data.qualification;
      } catch (e) {
        print('Error loading teacher dashboard cache: $e');
      }
    }
  }

  void _saveToCache(TeacherDashboardData data) {
    _storage.write(_cacheKey, data.toJson());
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final data = await _dashboardService.getDashboardData();
      teacherName.value = data.teacherName;
      schoolName.value = data.schoolName;
      rating.value = data.rating;
      qualification.value = data.qualification;

      _saveToCache(data);

      // Load notifications
      final notifs = _dashboardService.fetchNotifications();
      recentNotifications.assignAll(notifs);

      // Setup listeners
      _dashboardService.setupExamsListener();
      _dashboardService.setupTimetableListener();

      _updateUnreadCounts();
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCounts() {
    final schoolId = _authService.session.value?.schoolId ?? '';
    final userId = _authService.session.value?.userId ?? '';
    final schoolData = Get.find<SchoolDataService>();

    unreadNotificationCount.value = schoolData.getUnreadNotificationCount(
      schoolId,
      userId,
      roleAudience: NotificationAudience.teachers,
    );

    unreadMessageCount.value = schoolData.getUnreadMessageCount(
      schoolId,
      userId,
    );
  }

  // --- Getters ---
  RxList<UnifiedExamModel> get upcomingExams => _dashboardService.teacherExams;

  List<Map<String, String>> get assignedClasses {
    final Set<String> uniqueKeys = {};
    final List<Map<String, String>> result = [];

    // 1. From Timetable
    for (var slot in _dashboardService.teacherTimetable) {
      final key = '${slot.classNumber}-${slot.subjectName}';
      if (!uniqueKeys.contains(key)) {
        uniqueKeys.add(key);
        result.add({
          'classNumber': slot.classNumber,
          'subjectName': slot.subjectName,
        });
      }
    }

    // 2. From Formal Assignments
    final formal = _dashboardService.getAssignedClasses();
    for (var assignment in formal) {
      final key = '${assignment.classNumber}-${assignment.subjectName}';
      if (!uniqueKeys.contains(key)) {
        uniqueKeys.add(key);
        result.add({
          'classNumber': assignment.classNumber,
          'subjectName': assignment.subjectName,
        });
      }
    }

    return result;
  }

  Future<void> markNotificationRead(String id) async {
    final schoolId = _authService.session.value?.schoolId ?? '';
    await Get.find<SchoolDataService>().markNotificationAsRead(schoolId, id);
    _updateUnreadCounts();
  }

  void simulateNewNotification() {
    _dashboardService.simulateNotification(
      'Test Notification',
      'This is a test notification generated at ${DateTime.now()}',
      NotificationType.system,
    );
    // Refresh to show it
    final notifs = _dashboardService.fetchNotifications();
    recentNotifications.assignAll(notifs);
  }

  void navigateToAttendance(ClassTimetableSlotModel slot) {
    Get.toNamed(
      AppRoutes.teacherAttendanceMark,
      arguments: {'classId': slot.classNumber, 'subjectId': slot.subjectName},
    );
  }

  void logout() {
    _authService.logout();
  }

  Future<void> deleteExam(String examId) async {
    try {
      final authService = Get.find<AuthService>();
      final schoolId = authService.session.value?.schoolId;
      if (schoolId == null) return;

      await Get.find<SchoolDataService>().deleteExam(schoolId, examId);

      // Refresh
      upcomingExams.removeWhere((e) => e.id == examId);
      Get.snackbar('Success', 'Exam duty removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove exam: $e');
    }
  }
}
