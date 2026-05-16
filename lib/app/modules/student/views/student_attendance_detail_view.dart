import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_attendance_controller.dart';
import '../models/attendance_models.dart';
import '../../../data/models/attendance_record_model.dart';
import 'package:intl/intl.dart';

class StudentAttendanceDetailView extends GetView<StudentAttendanceController> {
  const StudentAttendanceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.selectedSummary.value?.monthName ?? 'Details',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final summary = controller.selectedSummary.value;
        if (summary == null) return const SizedBox();

        return Column(
          children: [
            _buildSummaryCard(summary),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentLime,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.currentMonthDetails.length,
                      itemBuilder: (context, index) {
                        final detail = controller.currentMonthDetails[index];
                        return _buildDetailTile(detail);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard(MonthlyAttendanceSummary summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.cardDark.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Present',
                summary.presentCount,
                Colors.greenAccent,
              ),
              _buildStatItem('Absent', summary.absentCount, Colors.redAccent),
              _buildStatItem('Leave', summary.leaveCount, Colors.blueAccent),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Percentage',
                style: TextStyle(color: Colors.white60),
              ),
              Text(
                '${summary.percentage.toInt()}%',
                style: const TextStyle(
                  color: AppColors.accentLime,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailTile(AttendanceRecordModel detail) {
    String dateStr = DateFormat('EEE, MMM d, yyyy').format(detail.date);

    Color statusColor;
    String statusLabel;

    switch (detail.status) {
      case AttendanceStatus.present:
        statusColor = Colors.greenAccent;
        statusLabel = 'Present';
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.redAccent;
        statusLabel = 'Absent';
        break;
      case AttendanceStatus.leave:
        statusColor = Colors.blueAccent;
        statusLabel = 'Leave';
        break;
      case AttendanceStatus.late:
        statusColor = Colors.orangeAccent;
        statusLabel = 'Late';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (detail.remarks != null)
                Text(
                  detail.remarks!,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
