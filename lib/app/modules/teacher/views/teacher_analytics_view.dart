import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../theme/app_colors.dart';

class TeacherAnalyticsView extends GetView<TeacherController> {
  const TeacherAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Performance Analytics',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentLime),
            onPressed: controller.refreshAnalytics,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isAnalyticsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(),
              const SizedBox(height: 24),
              _buildMetricCard(
                title: 'Class Attendance',
                icon: Icons.calendar_month,
                child: _buildAttendanceDetails(),
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                title: 'Assignment Completion',
                icon: Icons.assignment_turned_in,
                child: _buildAssignmentDetails(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Total Students',
            '${controller.totalStudentCount.value}',
            Icons.people,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Overall Attendance',
            '${((controller.attendanceSummary['overallPercentage'] ?? 0) * 100).toStringAsFixed(1)}%',
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentLime, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentLime, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildAttendanceDetails() {
    final Map<String, dynamic> breakdown =
        controller.attendanceSummary['classBreakdown'] ?? {};

    if (breakdown.isEmpty) {
      return const Text(
        'No attendance data available',
        style: TextStyle(color: Colors.white54),
      );
    }

    return Column(
      children: breakdown.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class ${e.key}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${(e.value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: e.value,
                backgroundColor: Colors.white12,
                color: AppColors.accentLime,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssignmentDetails() {
    final completion = controller.assignmentCompletion['completionRate'] ?? 0.0;
    final count = controller.assignmentCompletion['count'] ?? 0;
    final pending = controller.assignmentCompletion['pendingCount'] ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    color: AppColors.accentLime,
                  ),
                  Center(
                    child: Text(
                      '${(completion * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSimpleMetric('Total', '$count Assignments'),
                const SizedBox(height: 8),
                _buildSimpleMetric('Pending', '$pending Active'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
