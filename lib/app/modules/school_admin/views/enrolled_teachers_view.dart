import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../data/models/teacher_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class EnrolledTeachersView extends GetView<SchoolAdminController> {
  const EnrolledTeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Faculty Members',
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
          final teachers = controller.teachers;

          if (teachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No faculty members registered',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return _buildTeacherCard(teacher);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToRegisterTeacher,
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.add, color: AppColors.primaryBlack),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _showTeacherActions(teacher),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accentLime.withValues(alpha: 0.1),
                  child: Text(
                    teacher.name[0],
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        teacher.subjectSpecialization,
                        style: TextStyle(
                          color: AppColors.accentLime.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${teacher.qualification} • ${teacher.experienceYears}Y Exp',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white24,
                    size: 16,
                  ),
                  onPressed: () => _showTeacherActions(teacher),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTeacherActions(TeacherModel teacher) {
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
              'Actions for ${teacher.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              icon: Icons.person_search_outlined,
              title: 'View Profile Details',
              onTap: () {
                Get.back();
                controller.goToTeacherDetail(teacher.id);
              },
            ),
            _buildActionTile(
              icon: Icons.assignment_ind_outlined,
              title: 'Assign Classes & Subjects',
              onTap: () {
                Get.back();
                controller.showTeacherAssignmentDialog(teacher);
              },
            ),
            _buildActionTile(
              icon: Icons.delete_outline,
              title: 'Remove Faculty Member',
              color: Colors.redAccent,
              onTap: () {
                Get.back();
                Get.defaultDialog(
                  title: 'Remove Teacher?',
                  middleText:
                      'Are you sure you want to remove ${teacher.name}?',
                  textConfirm: 'Remove',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.redAccent,
                  onConfirm: () {
                    controller.removeTeacher(teacher.id);
                    Get.back();
                  },
                );
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
    Color color = AppColors.accentLime,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
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
