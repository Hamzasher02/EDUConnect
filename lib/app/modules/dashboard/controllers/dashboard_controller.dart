import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/school_model.dart';
import '../../../services/firestore_helper.dart';
import '../../../services/auth_service.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/school_data_service.dart';
import '../../../theme/app_colors.dart';

class DashboardController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final currentIndex = 0.obs;

  // Live Data
  final schools = <SchoolModel>[].obs;
  final allStudents = <Map<String, dynamic>>[].obs;
  final allTeachers = <Map<String, dynamic>>[].obs;
  final unreadNotificationCount = 0.obs;

  // Metrics
  int get totalStudents => schools
      .where((s) => s.status == 'active' || s.status == 'improving')
      .fold(0, (sum, item) => sum + item.studentCount);
  double get totalSubscription => schools
      .where((s) => s.status == 'active' || s.status == 'improving')
      .fold(0.0, (sum, item) => sum + item.subscriptionFee);
  int get totalTeachers => schools
      .where((s) => s.status == 'active' || s.status == 'improving')
      .fold(0, (sum, item) => sum + item.teacherCount);
  int get totalSchools => schools.length;

  @override
  void onInit() {
    super.onInit();
    // Worker to wait for session on app restart
    final authService = Get.find<AuthService>();
    ever(authService.session, (session) {
      if (session != null && session.role == UserRole.superAdmin) {
        _initSchoolsStream();
        _initGlobalDataStreams();
      }
    });

    if (authService.session.value != null &&
        authService.session.value!.role == UserRole.superAdmin) {
      _initSchoolsStream();
      _initGlobalDataStreams();
    }
  }

  void _initSchoolsStream() {
    schools.bindStream(
      FirestoreHelper.schools.snapshots().map(
        (query) => query.docs.map((doc) {
          return SchoolModel.fromJson(
            doc.data() as Map<String, dynamic>..['id'] = doc.id,
          );
        }).toList(),
      ),
    );

    // Track unread messages sent to Super Admin
    FirestoreHelper.db
        .collection('messages')
        .where('receiverId', isEqualTo: 'super_admin')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          final Map<String, int> counts = {};
          for (var doc in snapshot.docs) {
            final schoolId = doc.data()['schoolId'] as String?;
            if (schoolId != null) {
              counts[schoolId] = (counts[schoolId] ?? 0) + 1;
            }
          }
          rxUnreadMessagesBySchool.value = counts;
        });
  }

  void _initGlobalDataStreams() {
    // Fetch all students across all schools (assuming they are in a global collection or we need to aggregate)
    // For now, let's assume we can fetch from a global 'users' registry or similar if it exists,
    // or we fetch from school sub-collections (which is harder).
    // Based on register_student_view, they probably go into a school-specific collection.
    // However, for a "Super Admin" they might want to see all.
    // Let's check if there's a global students collection.
    allStudents.bindStream(
      FirestoreHelper.db
          .collectionGroup('students')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => doc.data()..['id'] = doc.id)
                .toList(),
          ),
    );

    allTeachers.bindStream(
      FirestoreHelper.db
          .collectionGroup('teachers')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => doc.data()..['id'] = doc.id)
                .toList(),
          ),
    );

    // Listen to Super Admin Notifications for unread count
    FirestoreHelper.db
        .collection('super_admin_notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          unreadNotificationCount.value = snapshot.docs.length;
        });
  }

  void changeTab(int index) {
    currentIndex.value = index;
    searchQuery.value = ''; // Reset search on tab change
  }

  void filterSchools(String query) {
    searchQuery.value = query;
  }

  List<SchoolModel> get filteredSchools {
    if (searchQuery.value.isEmpty) return schools;
    return schools
        .where(
          (s) => s.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  List<Map<String, dynamic>> get filteredStudents {
    if (searchQuery.value.isEmpty) return allStudents;
    return allStudents.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get filteredTeachers {
    if (searchQuery.value.isEmpty) return allTeachers;
    return allTeachers.where((t) {
      final name = (t['name'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // --- Tracking unread messages per school ---
  final Map<String, int> unreadMessagesBySchool = {};
  final RxMap<String, int> rxUnreadMessagesBySchool = <String, int>{}.obs;

  int getUnreadMessageCount(String schoolId) {
    return rxUnreadMessagesBySchool[schoolId] ?? 0;
  }

  Future<void> recalculateSchoolRankings() async {
    try {
      final schoolDataService = Get.find<SchoolDataService>();
      final schoolSnapshots = await FirestoreHelper.schools.get();

      for (var schoolDoc in schoolSnapshots.docs) {
        await schoolDataService.updateSchoolRankingScore(schoolDoc.id);
      }

      Get.snackbar(
        'Success',
        'All ${schoolSnapshots.docs.length} school rankings have been recalculated.',
        backgroundColor: AppColors.accentLime.withValues(alpha: 0.7),
        colorText: AppColors.primaryBlack,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to recalculate: $e');
    }
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.find<AuthService>().logout();
      },
    );
  }
}
