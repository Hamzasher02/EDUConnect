import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../models/school_admin_models.dart';
import '../../../routes/app_routes.dart';

class ManageSubjectsView extends GetView<SchoolAdminController> {
  const ManageSubjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Subject Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          final selectedClassName = controller.selectedClass.value;
          final classes = controller.base.schoolDataService.getClassesBySchool(
            controller.base.currentSchoolId,
          );
          
          final currentClass = classes.firstWhereOrNull(
            (c) => c.name == selectedClassName
          );

          if (currentClass == null) {
             return const Center(
              child: Text(
                'Please select a class from the student management screen first.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassTitleSection(currentClass),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subjects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSubjectDialog(currentClass.id, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLime,
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Subject'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSubjectList(currentClass.id),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClassTitleSection(ClassModel cls) {
    final TextEditingController nameController = TextEditingController(text: cls.name);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLASS NAME',
            style: TextStyle(
              color: AppColors.accentLime,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Class Name',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.renameClass(cls.id, cls.name, nameController.text.trim());
                },
                icon: const Icon(Icons.check_circle_outline, color: AppColors.accentLime),
                tooltip: 'Rename Class',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            cls.description ?? 'No description provided',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(String classId) {
    final subjects = controller.getSubjectsForClass(classId);
    
    if (subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.book_outlined, size: 48, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              const Text(
                'No subjects added for this class',
                style: TextStyle(color: Colors.white24),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final sub = subjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.adminSubjectPerformance,
              arguments: {'subjectName': sub.name, 'subjectId': sub.id},
            ),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLime.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.book, color: AppColors.accentLime, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (sub.description != null)
                          Text(
                            sub.description!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.analytics_outlined, color: Colors.white24, size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog(String classId, BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Subject', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Subject Name',
                labelStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              if (nameCtrl.text.isNotEmpty) {
                controller.subjectName.value = nameCtrl.text;
                controller.subjectDescription.value = descCtrl.text;
                controller.createSubject(classId);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentLime,
              foregroundColor: AppColors.primaryBlack,
            ),
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }
}
