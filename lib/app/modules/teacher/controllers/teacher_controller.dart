import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/teacher_models.dart';
import '../services/teacher_dashboard_service.dart';
import 'teacher_dashboard_controller.dart'; // Added
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
// For ClassTimetableSlotModel
import 'teacher_timetable_controller.dart';
import 'teacher_assignment_controller.dart';
import 'teacher_student_controller.dart'; // Added for search delegation
import '../../../core/utils/app_error_handler.dart';
import '../../../core/widgets/full_screen_loader.dart';

class TeacherController extends GetxController {
  // --- Profile State ---
  // Keeper of truth for Profile (can be accessed by other controllers if needed)
  final name = 'Sarah Khan'.obs;
  final school = 'Educated High School'.obs;
  final rating = 4.5.obs;
  final qualification = 'M.Sc Mathematics'.obs;
  final email = 'sarah.khan@teacher.com'.obs;
  final contact = '0300-1234567'.obs;
  final address = '123, Street 4, Islamabad'.obs;
  final bloodGroup = 'B+'.obs;
  final subjectsTaught = <String>['Mathematics', 'Physics'].obs;

  // --- App State ---
  final isOffline = false.obs;

  // --- Data Lists ---
  // Assignments might be needed for search or global access, keeping for now if not fully moved.
  // Timetable and Notifications are moved to specific controllers.

  // Analytics Data
  final attendanceSummary = {}.obs;
  final assignmentCompletion = {}.obs;
  final totalStudentCount = 0.obs;
  final isAnalyticsLoading = false.obs;
  final isExporting = false.obs;

  // Search & Filter State
  final searchQuery = ''.obs;
  final filters = FilterOptions.initial().obs;

  final isSearching = false.obs;

  // Workers for memory safety
  Worker? _searchWorker;

  // Messaging State
  // Replaced TeacherMessageModel with MessageModel
  final inbox = <MessageModel>[].obs;
  final activeConversation = <MessageModel>[].obs;
  final isSending = false.obs;
  final activePartnerId = ''.obs;

  // Settings Data
  late Rx<TeacherSettingsModel> settings;

  final authService = Get.find<AuthService>();
  final schoolDataService = Get.find<SchoolDataService>();
  String get currentSchoolId => authService.session.value?.schoolId ?? '';

  final _dashboardService =
      Get.find<
        TeacherDashboardService
      >(); // Changed to find to share instance if put elsewhere

  @override
  void onInit() {
    super.onInit();
    // Initialize settings reactively
    settings = _dashboardService.fetchSettings().obs;

    // Split loaders for better performance/responsiveness
    _loadAnalytics();
    _loadInbox();

    // Setup debounced search worker
    _searchWorker = debounce(
      searchQuery,
      (_) => performSearch(),
      time: const Duration(milliseconds: 300),
    );

    // Initial data load for search view
    performSearch();

    fetchProfile();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await _dashboardService.getDashboardData();
      // Update State
      name.value = data.teacherProfile.name;
      school.value = data.schoolName;
      rating.value = data.rating;
      qualification.value = data.teacherProfile.qualification;
      email.value = data.teacherProfile.email;
      contact.value = data.teacherProfile.contactNumber;
      address.value = data.teacherProfile.address ?? '';
      bloodGroup.value = data.teacherProfile.bloodGroup ?? '';
      subjectsTaught.assignAll(data.teacherProfile.subjectsTaught);
    } catch (e) {
      // Silent or partial load
    }
  }

  Future<void> _loadAnalytics() async {
    await loadAnalytics();
  }

  void _loadInbox() {
    loadInbox();
  }

  // --- Methods ---

  void toggleOfflineMode() {
    // Toggle local state
    isOffline.value = !isOffline.value;

    // Sync with SchoolDataService
    _dashboardService.setOfflineMode(
      isOffline.value,
    ); // Assuming method exists or added

    Get.snackbar(
      'Offline mode is now ${isOffline.value ? 'ON' : 'OFF'}',
      isOffline.value
          ? 'Changes will be queued for sync'
          : 'Syncing pending changes...',
    );

    if (!isOffline.value) {
      syncOfflineChanges();
    }
  }

  Future<void> syncOfflineChanges() async {
    try {
      Get.dialog(
        const Center(child: FullScreenLoader(message: 'Syncing changes...')),
        barrierDismissible: false,
      );
      await _dashboardService.syncPendingUpdates();
      if (Get.isDialogOpen ?? false) Get.back();
      AppErrorHandler.showSuccess('All changes synchronized');
      // Refresh data
      fetchProfile();
      _loadAnalytics();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppErrorHandler.show('Sync failed: $e');
    }
  }

  // --- Analytics ---

  Future<void> loadAnalytics() async {
    try {
      isAnalyticsLoading.value = true;
      attendanceSummary.value = _dashboardService.fetchAttendanceSummary();
      assignmentCompletion.value = _dashboardService
          .fetchAssignmentCompletion();
      totalStudentCount.value = _dashboardService.fetchStudentCounts();
    } catch (e) {
      // Silent error or log
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  // --- Settings ---

  void fetchSettings() {
    settings.value = _dashboardService.fetchSettings();
  }

  void saveSettings(TeacherSettingsModel updatedSettings) {
    _dashboardService.updateSettings(updatedSettings);
    settings.value = updatedSettings;

    // Apply theme changes immediately
    Get.changeThemeMode(
      updatedSettings.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
    );

    Get.snackbar(
      'Success',
      'Settings saved successfully',
      backgroundColor: Colors.green.withValues(alpha: 0.7),
      colorText: Colors.white,
    );
  }

  // --- Export & Reporting ---

  Future<void> exportTimetable() async {
    try {
      isExporting.value = true;
      await _dashboardService.exportTimetable();
      _updateLastExport();
      Get.snackbar(
        'Export Success',
        'Timetable exported to CSV',
        backgroundColor: Colors.blue.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Export Error', e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportStudentList(String classId) async {
    try {
      isExporting.value = true;
      await _dashboardService.exportStudentList(classId);
      _updateLastExport();
      Get.snackbar(
        'Export Success',
        'Student list for $classId exported to CSV',
        backgroundColor: Colors.blue.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Export Error', e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportAnalyticsReport() async {
    try {
      isExporting.value = true;
      await _dashboardService.exportAnalyticsReport();
      _updateLastExport();
      Get.snackbar(
        'Export Success',
        'Analytics report exported to PDF',
        backgroundColor: Colors.blue.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Export Error', e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  void _updateLastExport() {
    final updatedSettings = settings.value.copyWith(
      lastExportTimestamp: DateTime.now(),
    );
    saveSettings(updatedSettings);
  }

  // --- Search & Filters ---

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    performSearch();
  }

  void updateFilters(FilterOptions newFilters) {
    filters.value = newFilters;
    performSearch();
  }

  void resetFilters() {
    filters.value = FilterOptions();
    searchQuery.value = '';
    performSearch();
  }

  void performSearch() {
    isSearching.value = true;

    // Delegate to Student Search
    if (Get.isRegistered<TeacherStudentController>()) {
      Get.find<TeacherStudentController>().searchStudents(
        searchQuery.value,
        classId: filters.value.classId,
      );
    }

    // Delegate to Timetable Controller
    if (Get.isRegistered<TeacherTimetableController>()) {
      Get.find<TeacherTimetableController>().filterTimetable(
        day: filters.value.day,
        subject: filters.value.subject,
        classId: filters.value.classId,
      );
    }

    // Delegate to Assignment Controller
    if (Get.isRegistered<TeacherAssignmentController>()) {
      Get.find<TeacherAssignmentController>().filterAssignments(
        classId: filters.value.classId,
        completed: filters.value.completed,
      );
    }

    isSearching.value = false;
  }

  // --- Derived Getters (Restored for View Compatibility) ---

  List<ClassTimetableSlotModel> get fullTimetable =>
      _dashboardService.teacherTimetable;

  List<String> get uniqueSubjects {
    return fullTimetable.map((s) => s.subjectName).toSet().toList();
  }

  List<String> get daysOfWeek => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<ClassTimetableSlotModel> getTimetableForDay(String day) {
    return fullTimetable.where((slot) => slot.day == day).toList();
  }

  List<String> get uniqueClassNames {
    final names = <String>{};
    for (var slot in fullTimetable) {
      names.add('Class ${slot.classNumber}');
    }
    return names.toList()..sort();
  }

  // --- Messaging Methods ---

  void loadInbox() {
    inbox.assignAll(_dashboardService.fetchInbox());
  }

  void openConversation(String partnerId) {
    activePartnerId.value = partnerId;
    activeConversation.assignAll(
      _dashboardService.fetchConversation(partnerId),
    );

    // Mark messages as read
    for (final msg in activeConversation) {
      if (!msg.isRead && msg.receiverId == _dashboardService.userId) {
        _dashboardService.markAsRead(msg.id);
      }
    }
    loadInbox(); // Refresh unread count in inbox
  }

  Future<void> sendMessage(String partnerId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      isSending.value = true;
      if (partnerId == 'admin_1') {
        await _dashboardService.sendMessageToAdmin(content);
      } else {
        await _dashboardService.sendMessageToParent(
          studentId: partnerId,
          content: content,
        );
      }
      openConversation(partnerId); // Refresh conversation
    } catch (e) {
      AppErrorHandler.show('Failed to send message: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> updateProfile(
    String newName,
    String newContact,
    String newAddress,
    String newQual,
    String newBlood,
  ) async {
    if (isOffline.value) {
      Get.snackbar('Error', 'Cannot update profile offline');
      return;
    }

    try {
      await _dashboardService.updateTeacherFields(
        name: newName,
        contact: newContact,
        address: newAddress,
        qualification: newQual,
        bloodGroup: newBlood,
      );

      // Optimistic Update
      name.value = newName;
      contact.value = newContact;
      address.value = newAddress;
      qualification.value = newQual;
      bloodGroup.value = newBlood;

      Get.snackbar('Success', 'Profile updated successfully');

      // Notify dashboard controller to update its state too?
      // It fetches data on init, but might need refresh.
      // For now, simple state update here is okay.
      if (Get.isRegistered<TeacherDashboardController>()) {
        Get.find<TeacherDashboardController>().loadDashboardData();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void signOut() {
    isOffline.value = false;
    Get.find<AuthService>().logout();
  }
}
