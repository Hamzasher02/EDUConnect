import 'package:get/get.dart';
import '../../../services/school_data_service.dart';
import '../../../services/auth_service.dart';
import '../models/school_admin_models.dart';
import '../../dashboard/models/school_model.dart';

class BaseAdminController extends GetxController {
  final schoolName = 'Loading...'.obs;
  final schoolCategory = 'Evaluated'.obs;
  final subscriptionFee = 0.0.obs;
  final schoolStatus = ''.obs;
  final isVisibleOnRanking = true.obs;
  
  String get currentSchoolId => authService.session.value?.schoolId ?? '';

  final isOffline = false.obs;
  final selectedClass = ''.obs;
  final classList = <ClassModel>[].obs;
  final unreadNotificationCount = 0.obs;
  final unreadMessageCount = 0.obs;

  final SchoolDataService schoolDataService = Get.find<SchoolDataService>();
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // Worker to wait for session on app restart
    ever(authService.session, (session) {
      if (session != null && classList.isEmpty) {
        _loadInitialData();
      }
    });

    // Worker to listen for school data changes
    ever(schoolDataService.schoolsData, (map) {
      final data = map[currentSchoolId];
      if (data != null) {
        final school = SchoolModel.fromJson(data);
        schoolName.value = school.name;
        schoolCategory.value = school.category;
        subscriptionFee.value = school.subscriptionFee;
        schoolStatus.value = school.status;
        isVisibleOnRanking.value = school.isVisibleOnRanking;
      }
    });

    if (authService.session.value != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    // Initial fetch to ensure data is present
    classList.assignAll(schoolDataService.getClasses(currentSchoolId));

    final schoolClasses = schoolDataService.classes[currentSchoolId];
    if (schoolClasses != null) {
      classList.bindStream(schoolClasses.stream);
    } else {
      ever(schoolDataService.classes, (map) {
        final list = map[currentSchoolId];
        if (list != null) {
          classList.bindStream(list.stream);
        }
      });
    }

    _setupUnreadCountListeners();
    _updateUnreadCounts();
  }

  void _setupUnreadCountListeners() {
    final sId = currentSchoolId;

    // Notifications listener
    final notifs = schoolDataService.notifications[sId];
    if (notifs != null) {
      ever(notifs, (_) => _updateUnreadCounts());
    } else {
      ever(schoolDataService.notifications, (map) {
        final list = map[sId];
        if (list != null) ever(list, (_) => _updateUnreadCounts());
      });
    }

    // Messages listener
    final msgs = schoolDataService.messages[sId];
    if (msgs != null) {
      ever(msgs, (_) => _updateUnreadCounts());
    } else {
      ever(schoolDataService.messages, (map) {
        final list = map[sId];
        if (list != null) ever(list, (_) => _updateUnreadCounts());
      });
    }
  }

  void _updateUnreadCounts() {
    final schoolId = currentSchoolId;
    final userId = authService.session.value?.userId ?? '';

    unreadNotificationCount.value = schoolDataService
        .getUnreadNotificationCount(
          schoolId,
          userId,
          roleAudience: NotificationAudience.wholeSchool,
        );

    unreadMessageCount.value = schoolDataService.getUnreadMessageCount(
      schoolId,
      userId,
    );
  }

  void selectClass(String className) {
    selectedClass.value = className;
  }

  bool guardSelectedClass() {
    if (selectedClass.value.isEmpty) {
      Get.snackbar('Error', 'Please select a class first.');
      return false;
    }
    return true;
  }

  void toggleOffline() {
    isOffline.value = !isOffline.value;
    Get.snackbar(
      isOffline.value ? 'Offline Mode' : 'Online Mode',
      isOffline.value
          ? 'You are now offline. Some actions are disabled.'
          : 'You are back online.',
    );
  }
}
