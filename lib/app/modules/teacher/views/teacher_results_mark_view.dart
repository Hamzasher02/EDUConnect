import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_result_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class TeacherResultsMarkView extends GetView<TeacherResultController> {
  const TeacherResultsMarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedClass = controller.assignedClasses.firstWhereOrNull(
      (c) => c.id == controller.selectedClassId.value,
    );

    if (selectedClass == null) {
      Future.microtask(() => Get.back());
      return const Scaffold(backgroundColor: AppColors.primaryBlack);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Results',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
            Text(
              '${selectedClass.classNumber} - ${selectedClass.subjectName}',
              style: const TextStyle(color: AppColors.accentLime, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.isOffline.value) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent,
                child: const Text(
                  'Offline Mode: Cannot submit results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.studentsMarks.length,
                itemBuilder: (context, index) {
                  final student = controller.studentsMarks[index];
                  return GlassContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.accentLime.withValues(alpha: 0.1),
                              child: Text(
                                student.name.isNotEmpty ? student.name[0] : '?',
                                style: const TextStyle(color: AppColors.accentLime),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Roll No: ${student.rollNo}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMarkInput(
                                'Midterm',
                                (val) => student.midtermMarks = val,
                                student.midtermMarks,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMarkInput(
                                'Final',
                                (val) => student.finalMarks = val,
                                student.finalMarks,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isOffline.value
                      ? null
                      : controller.submitResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Submit Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkInput(
    String label,
    Function(String) onChanged,
    String initialValue,
  ) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: AppColors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }
}
