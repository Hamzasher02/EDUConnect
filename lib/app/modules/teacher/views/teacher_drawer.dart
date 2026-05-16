import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class TeacherDrawer extends GetView<TeacherController> {
  const TeacherDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.accentLime),
            accountName: Obx(
              () => Text(
                controller.name.value,
                style: const TextStyle(
                  color: AppColors.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountEmail: Obx(
              () => Text(
                controller.email.value,
                style: const TextStyle(color: AppColors.primaryBlack),
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.primaryBlack,
              child: Icon(Icons.person, color: AppColors.white, size: 40),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Profile',
            route: AppRoutes.teacherProfile,
          ),
          _buildDrawerItem(
            icon: Icons.check_circle_outline,
            title: 'Attendance',
            route: AppRoutes.teacherAttendanceClasses,
          ),
          _buildDrawerItem(
            icon: Icons.create_outlined,
            title: 'Results',
            route: AppRoutes.teacherResultsClasses,
          ),
          _buildDrawerItem(
            icon: Icons.notifications_none,
            title: 'Notifications',
            route: AppRoutes.teacherNotifications,
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today_outlined,
            title: 'Timetable',
            route: AppRoutes.teacherTimetable,
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'My Students',
            route: AppRoutes.teacherMyStudents,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_outlined,
            title: 'Analytics',
            route: AppRoutes.teacherAnalytics,
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            route: AppRoutes.teacherSettings,
          ),
          _buildDrawerItem(
            icon: Icons.description_outlined,
            title: 'Reports',
            route: AppRoutes.teacherReports,
          ),
          _buildDrawerItem(
            icon: Icons.search_outlined,
            title: 'Search',
            route: AppRoutes.teacherSearch,
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            title: 'Messages',
            route: AppRoutes.teacherInbox,
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Get.back(); // Close drawer
              controller.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white),
      title: Text(title, style: const TextStyle(color: AppColors.white)),
      onTap: () {
        Get.back(); // Close drawer first
        Get.toNamed(route);
      },
    );
  }
}
