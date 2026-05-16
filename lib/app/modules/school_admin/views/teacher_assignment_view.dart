import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/student_model.dart';

class TeacherAssignmentView extends GetView<SchoolAdminController> {
  const TeacherAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Assign Teachers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final classes = controller.base.schoolDataService.getClassesBySchool(
          controller.base.currentSchoolId,
        );

        if (classes.isEmpty) {
          return const Center(
            child: Text(
              'No classes found.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final cls = classes[index];
            return _buildAssignmentCard(cls, context);
          },
        );
      }),
    );
  }

  Widget _buildAssignmentCard(ClassModel cls, BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              cls.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Assigned Teachers per Subject',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: AppColors.accentLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: AppColors.accentLime,
                ),
                onPressed: () => _showAssignmentDialog(cls, context),
              ),
            ),
          ),
          _buildCurrentAssignments(cls.id),
        ],
      ),
    );
  }

  Widget _buildCurrentAssignments(String classId) {
    return Obx(() {
      final assignments = controller.base.schoolDataService
          .getTeacherAssignmentsBySchool(controller.base.currentSchoolId)
          .where((a) => a.classId == classId)
          .toList();

      if (assignments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No assignments yet',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final a = assignments[index];
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.assignment_ind_outlined,
              color: Colors.white54,
              size: 18,
            ),
            title: Text(
              '${a.subjectName}: ${a.teacherName}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 18,
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Remove Assignment',
                  middleText:
                      'Are you sure you want to remove this assignment?',
                  textConfirm: 'Yes',
                  textCancel: 'No',
                  confirmTextColor: Colors.black,
                  buttonColor: AppColors.accentLime,
                  onConfirm: () {
                    controller.deleteTeacherAssignment(a.id);
                    Get.back();
                  },
                );
              },
            ),
          );
        },
      );
    });
  }

  void _showAssignmentDialog(ClassModel cls, BuildContext context) {
    final teachers = controller.base.schoolDataService.getTeachersBySchool(
      controller.base.currentSchoolId,
    );
    final subjects = controller.getSubjectsForClass(cls.id);

    if (teachers.isEmpty || subjects.isEmpty) {
      Get.snackbar(
        'Cannot Assign',
        'Please ensure you have both Teachers and Subjects added.',
      );
      return;
    }

    controller.assignmentTeacherId.value = '';
    controller.assignmentSubjectId.value = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Assign to ${cls.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => DropdownButtonFormField<String>(
                dropdownColor: AppColors.cardDark,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
                items: subjects
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  controller.assignmentSubjectId.value = v ?? '';
                  controller.assignmentSubjectName.value = subjects
                      .firstWhere((s) => s.id == v)
                      .name;
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                dropdownColor: AppColors.cardDark,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Teacher',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
                items: teachers
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  controller.assignmentTeacherId.value = v ?? '';
                  controller.assignmentTeacherName.value = teachers
                      .firstWhere((t) => t.id == v)
                      .name;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.assignTeacherToSubject(cls.id, cls.name);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentLime,
            ),
            child: const Text('Assign', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
