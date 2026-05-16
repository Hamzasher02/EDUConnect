import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/student_exam_controller.dart';
import '../models/exam_models.dart';
import '../../../widgets/glass_container.dart';

class StudentExamView extends GetView<StudentExamController> {
  const StudentExamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Examination Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        if (controller.exams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No upcoming exams scheduled',
                  style: TextStyle(color: Colors.white24, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: controller.exams.length,
          itemBuilder: (context, index) {
            final exam = controller.exams[index];
            return _buildExamCard(exam);
          },
        );
      }),
    );
  }

  Widget _buildExamCard(StudentExamModel exam) {
    final isToday = exam.examDate.day == DateTime.now().day;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.studentExamDetail, arguments: exam),
      child: Container(
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
                              color: AppColors.accentLime.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exam.examType.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accentLime,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 18,
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
                            '${exam.startTime} - ${exam.endTime}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.accentLime,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            exam.location ?? 'TBD',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
