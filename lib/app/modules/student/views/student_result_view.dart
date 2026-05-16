import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_result_controller.dart';
import '../models/result_models.dart';
import '../../../utils/grade_utils.dart';
import 'student_result_detail_view.dart';

class StudentResultView extends GetView<StudentResultController> {
  const StudentResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Exam Results',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.examSummaries.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        if (controller.examSummaries.isEmpty) {
          return const Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshResults(),
          color: AppColors.accentLime,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.examSummaries.length,
            itemBuilder: (context, index) {
              final summary = controller.examSummaries[index];
              return _buildExamCard(summary);
            },
          ),
        );
      }),
    );
  }

  Widget _buildExamCard(ExamSummaryModel summary) {
    final percentage = summary.percentage;
    final label = GradeUtility.getPerformanceLabel(percentage);

    return GestureDetector(
      onTap: () {
        controller.selectExam(summary);
        Get.to(() => const StudentResultDetailView());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.examName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Performance: $label',
                        style: TextStyle(
                          color: percentage >= 70
                              ? AppColors.accentLime
                              : Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(
                  'GPA',
                  GradeUtility.getGPA(percentage).toStringAsFixed(1),
                ),
                _buildMetric('Grade', GradeUtility.getGrade(percentage)),
                _buildMetric(
                  'Status',
                  percentage >= 50 ? 'Passed' : 'Fail',
                  color: percentage >= 50
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
