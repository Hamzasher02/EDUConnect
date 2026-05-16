import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_result_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class TeacherResultsClassesView extends GetView<TeacherResultController> {
  const TeacherResultsClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Enter Results',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Obx(() {
        if (controller.assignedClasses.isEmpty) {
          return const Center(
            child: Text(
              'No classes assigned.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.assignedClasses.length,
          itemBuilder: (context, index) {
            final cls = controller.assignedClasses[index];
            return Card(
              color: AppColors.cardDark,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlack.withValues(
                    alpha: 0.7,
                  ),
                  child: const Icon(Icons.grade, color: AppColors.accentLime),
                ),
                title: Text(
                  cls.classNumber,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  cls.subjectName,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
                onTap: () {
                  controller.fetchStudents(cls.classNumber, cls.subjectName);
                  Get.toNamed(
                    AppRoutes.teacherResultsMark,
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
