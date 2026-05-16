import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class ScheduleExamView extends GetView<SchoolAdminController> {
  const ScheduleExamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(
          () => Text(
            'Schedule: ${controller.selectedExamClass.value}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlack,
              Color(0xFF0F0F0F),
              Color(0xFF1E1E1E),
            ],
          ),
        ),
        child: Obx(() {
          final isLocked = controller.isExamScheduleLocked;
          final subjects = controller.examScheduleFormSubjects;

          return Column(
            children: [
              const SizedBox(height: 100),
              if (isLocked)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GlassContainer(
                    // ignore: deprecated_member_use
                    color: Colors.orange.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_clock_outlined, color: Colors.orangeAccent),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Schedule is locked for past exam dates",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoBanner(subjects.length),
                      const SizedBox(height: 24),
                      if (subjects.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.subject_outlined,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No subjects assigned to this class",
                                  style: TextStyle(color: Colors.white24),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            return _buildProfessionalSubjectCard(
                              context,
                              subjects[index],
                              index,
                              isLocked,
                            );
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final isLocked = controller.isExamScheduleLocked;
        final isOffline = controller.isOffline.value;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: _buildSubmitButton(isLocked || isOffline),
        );
      }),
    );
  }

  Widget _buildInfoBanner(int subjectCount) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.accentLime, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Please configure the exam date and time for all $subjectCount subjects. This schedule will be shared instantly with students and assigned faculty.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSubjectCard(
    BuildContext context,
    ExamSubjectScheduleModel subject,
    int index,
    bool isLocked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.accentLime.withValues(alpha: 0.2),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  subject.subjectName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPickerField(
                    label: 'Exam Date',
                    value: DateFormat('EEE, MMM dd').format(subject.examDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: isLocked ? null : () => _selectDate(context, subject),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerField(
                    label: 'Start Time',
                    value: subject.examTime.format(context),
                    icon: Icons.access_time,
                    onTap: isLocked ? null : () => _selectTime(context, subject),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.accentLime),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDisabled) {
    return GestureDetector(
      onTap: isDisabled ? null : () => controller.submitExamSchedule(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.white12 : AppColors.accentLime,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.accentLime.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Center(
          child: Text(
            'Save & Distribute Schedule',
            style: TextStyle(
              color: isDisabled ? Colors.white24 : AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ExamSubjectScheduleModel subject,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: subject.examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _buildThemePicker(child!),
    );
    if (picked != null) {
      subject.examDate = picked;
      controller.examScheduleFormSubjects.refresh();
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    ExamSubjectScheduleModel subject,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: subject.examTime,
      builder: (context, child) => _buildThemePicker(child!),
    );
    if (picked != null) {
      subject.examTime = picked;
      controller.examScheduleFormSubjects.refresh();
    }
  }

  Widget _buildThemePicker(Widget child) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentLime,
          onPrimary: Colors.black,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.accentLime),
        ),
      ),
      child: child,
    );
  }
}
