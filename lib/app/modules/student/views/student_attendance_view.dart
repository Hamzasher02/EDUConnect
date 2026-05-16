import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_attendance_controller.dart';
import '../models/attendance_models.dart';
import 'student_attendance_detail_view.dart';

class StudentAttendanceView extends GetView<StudentAttendanceController> {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summaries.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        if (controller.summaries.isEmpty && controller.subjectSummaries.isEmpty) {
          return const Center(
            child: Text(
              'No attendance records found',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAttendance(),
          color: AppColors.accentLime,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.subjectSummaries.isNotEmpty) ...[
                  const Text(
                    'Subject Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.subjectSummaries.length,
                      itemBuilder: (context, index) {
                        final sub = controller.subjectSummaries[index];
                        return _buildSubjectCard(sub);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                const Text(
                  'Monthly History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.summaries.length,
                  itemBuilder: (context, index) {
                    final summary = controller.summaries[index];
                    return _buildMonthCard(summary);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubjectCard(SubjectAttendanceSummary sub) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: sub.percentage / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: AppColors.accentLime,
                  strokeWidth: 4,
                ),
              ),
              Text(
                '${sub.percentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub.subject,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(MonthlyAttendanceSummary summary) {
    Color indicatorColor;
    if (summary.percentage >= 85) {
      indicatorColor = Colors.greenAccent;
    } else if (summary.percentage >= 70) {
      indicatorColor = Colors.amberAccent;
    } else {
      indicatorColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: () {
        controller.loadMonthDetails(summary);
        Get.to(() => const StudentAttendanceDetailView());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.monthName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: indicatorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${summary.percentage.toInt()}%',
                style: TextStyle(
                  color: indicatorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}
