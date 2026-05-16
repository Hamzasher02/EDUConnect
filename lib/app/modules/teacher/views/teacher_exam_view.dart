import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/teacher_exam_controller.dart';
import '../../../data/models/exam_model.dart';
import '../../../widgets/glass_container.dart';

class TeacherExamView extends GetView<TeacherExamController> {
  const TeacherExamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Exam Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final exams = controller.scheduledExams;

        if (exams.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No exams scheduled yet',
                  style: TextStyle(color: Colors.white24, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showScheduleBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                  ),
                  child: const Text('Schedule First Exam'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (controller.isLoading.value)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppColors.accentLime,
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return _buildTeacherExamCard(exam);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleBottomSheet(context),
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.add, color: AppColors.primaryBlack),
      ),
    );
  }

  void _showScheduleBottomSheet(BuildContext context) {
    // Reset form
    controller.selectedClass.value = '';
    controller.selectedSubject.value = '';
    controller.examName.value = 'Class Test';
    controller.examDate.value = DateTime.now();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule New Exam',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Obx(
                () => _buildDropdownField(
                  'Select Class',
                  controller.selectedClass,
                  controller.uniqueAssignedClasses.isEmpty
                      ? ['No classes assigned']
                      : controller.uniqueAssignedClasses,
                ),
              ),
              const SizedBox(height: 16),

              Obx(
                () => _buildDropdownField(
                  'Select Subject',
                  controller.selectedSubject,
                  controller.selectedClass.value.isEmpty
                      ? ['Select Class First']
                      : (controller
                                .getSubjectsForClass(
                                  controller.selectedClass.value,
                                )
                                .isEmpty
                            ? ['No subjects found']
                            : controller.getSubjectsForClass(
                                controller.selectedClass.value,
                              )),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Exam Name / Title'),
                onChanged: (v) => controller.examName.value = v,
                controller: TextEditingController(
                  text: controller.examName.value,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.examDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null) controller.examDate.value = picked;
                      },
                      child: Obx(
                        () => InputDecorator(
                          decoration: _fieldDecoration('Date'),
                          child: Text(
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(controller.examDate.value),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: controller.startTime.value,
                        );
                        if (picked != null) controller.startTime.value = picked;
                      },
                      child: Obx(
                        () => InputDecorator(
                          decoration: _fieldDecoration('Time'),
                          child: Text(
                            controller.startTime.value.format(context),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.submitExam(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SCHEDULE EXAM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdownField(String label, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Obx(
            () => DropdownButton<String>(
              value: value.value.isEmpty ? null : value.value,
              dropdownColor: const Color(0xFF2A2A2A),
              underline: const SizedBox(),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.accentLime,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null &&
                    v != 'No classes assigned' &&
                    v != 'Select Class First' &&
                    v != 'No subjects found') {
                  value.value = v;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentLime),
      ),
    );
  }

  Widget _buildTeacherExamCard(UnifiedExamModel exam) {
    final isToday =
        exam.examDate.day == DateTime.now().day &&
        exam.examDate.month == DateTime.now().month &&
        exam.examDate.year == DateTime.now().year;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildDateColumn(exam.examDate, isToday),
            const SizedBox(width: 16),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CLASS ${exam.classNumber}',
                            style: const TextStyle(
                              color: AppColors.accentLime,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          exam.type.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Remove Exam Duty',
                              backgroundColor: const Color(0xFF1A1A1A),
                              titleStyle: const TextStyle(color: Colors.white),
                              middleTextStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              middleText:
                                  'Are you sure you want to remove the exam for "${exam.subject}"?',
                              textConfirm: 'Remove',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.redAccent,
                              onConfirm: () {
                                controller.deleteExam(exam.id);
                                Get.back();
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exam.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.examName,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.accentLime,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          exam.startTime,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.teacherResultsMark,
                              arguments: {
                                'classId': exam.classNumber,
                                'subjectId': exam.subject,
                              },
                            );
                          },
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text(
                            'Enter Marks',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentLime.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.accentLime,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateColumn(DateTime date, bool isToday) {
    return Column(
      children: [
        Text(
          DateFormat('MMM').format(date).toUpperCase(),
          style: TextStyle(
            color: isToday ? AppColors.accentLime : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('dd').format(date),
          style: TextStyle(
            color: isToday ? AppColors.accentLime : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Expanded(
          child: VerticalDivider(color: Colors.white10, thickness: 1),
        ),
      ],
    );
  }
}
