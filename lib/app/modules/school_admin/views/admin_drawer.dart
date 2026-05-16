import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/school_admin_controller.dart';

class AdminDrawer extends GetView<SchoolAdminController> {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlack.withValues(alpha: 0.95),
          border: Border(
            right: BorderSide(
              // ignore: deprecated_member_use
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.accentLime.withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 48,
                    color: AppColors.accentLime,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      controller.schoolName.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'Administrative Panel',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              onTap: () => Get.back(),
            ),
            _buildItem(
              icon: Icons.people_outline,
              title: 'Manage Students',
              onTap: () => Get.toNamed(AppRoutes.adminManageStudents),
            ),
            _buildItem(
              icon: Icons.school_outlined,
              title: 'Manage Teachers',
              onTap: () => Get.toNamed(AppRoutes.adminManageTeachers),
            ),
            _buildItem(
              icon: Icons.assignment_outlined,
              title: 'Examinations',
              onTap: () => Get.toNamed(AppRoutes.adminManageExams),
            ),
            _buildItem(
              icon: Icons.assignment_ind_outlined,
              title: 'Assign Teachers',
              onTap: () => Get.toNamed(AppRoutes.adminTeacherAssignment),
            ),
            _buildItem(
              icon: Icons.analytics_outlined,
              title: 'Reports Hub',
              onTap: () => Get.toNamed(AppRoutes.adminReportsHub),
            ),
            _buildItem(
              icon: Icons.schedule_outlined,
              title: 'Timetables',
              onTap: () => Get.toNamed(AppRoutes.adminClassTimetableHub),
            ),
            _buildItem(
              icon: Icons.archive_outlined,
              title: 'Archive Queue',
              onTap: () => Get.toNamed(AppRoutes.adminArchiveQueue),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white12),
            ),
            _buildItem(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              color: Colors.redAccent,
              onTap: () => controller.base.authService.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color.withValues(alpha: 0.7), size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
