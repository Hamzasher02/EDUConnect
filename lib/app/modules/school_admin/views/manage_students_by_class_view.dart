import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class ManageStudentsByClassView extends GetView<SchoolAdminController> {
  const ManageStudentsByClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Students',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: Obx(() {
          // Track inner list counts
          final _ = controller.student.studentsByClass.values.fold(
            0,
            (sum, list) => sum + list.length,
          );

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: controller.base.classList.length,
            itemBuilder: (context, index) {
              final classInfo = controller.base.classList[index];
              final studentCount =
                  controller.student.studentsByClass[classInfo.name]?.length ??
                  0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    controller.base.selectClass(classInfo.name);
                    _showStudentActions(context, classInfo.name);
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.class_outlined,
                            color: AppColors.accentLime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classInfo.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$studentCount Students Enrolled',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.accentLime,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/admin-create-class'),
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.add, color: AppColors.primaryBlack),
      ),
    );
  }

  void _showStudentActions(BuildContext context, String className) {
    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Actions for $className',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              icon: Icons.list_alt_outlined,
              title: 'View Enrolled Students',
              onTap: () {
                Get.back();
                Get.toNamed('/admin-view-enrolled-students');
              },
            ),
            _buildActionTile(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Register New Student',
              onTap: () {
                Get.back();
                Get.toNamed('/admin-register-student');
              },
            ),
            _buildActionTile(
              icon: Icons.payments_outlined,
              title: 'Fee Management',
              onTap: () {
                Get.back();
                Get.toNamed('/admin-manage-fee');
              },
            ),
            _buildActionTile(
              icon: Icons.book_outlined,
              title: 'Subject Management',
              onTap: () {
                Get.back();
                Get.toNamed('/admin-manage-subjects');
              },
            ),
            _buildActionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Class Timetable',
              onTap: () {
                Get.back();
                controller.timetable.goToClassTimetable(className);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentLime),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 14,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
