import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_assignment_controller.dart';
import '../models/assignment_models.dart';
import 'student_assignment_detail_view.dart';

class StudentAssignmentView extends GetView<StudentAssignmentController> {
  const StudentAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Assignments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.assignments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        if (controller.assignments.isEmpty) {
          return const Center(
            child: Text(
              'No assignments found',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAssignments(),
          color: AppColors.accentLime,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.assignments.length,
            itemBuilder: (context, index) {
              final vm = controller.assignments[index];
              return StudentAssignmentCard(vm: vm);
            },
          ),
        );
      }),
    );
  }
}

class StudentAssignmentCard extends GetView<StudentAssignmentController> {
  final StudentAssignmentViewModel vm;

  const StudentAssignmentCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final status = vm.calculatedStatus;
    Color statusColor;
    String statusText;

    switch (status) {
      case SubmissionStatus.submitted:
        statusColor = Colors.greenAccent;
        statusText = 'Submitted';
        break;
      case SubmissionStatus.late:
        statusColor = Colors.redAccent;
        statusText = 'Late';
        break;
      case SubmissionStatus.graded:
        statusColor = AppColors.accentLime;
        statusText = 'Graded';
        break;
      case SubmissionStatus.notSubmitted:
        statusColor = Colors.orangeAccent;
        statusText = 'Pending';
        break;
    }

    return GestureDetector(
      onTap: () {
        controller.selectAssignment(vm);
        Get.to(() => const StudentAssignmentDetailView());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vm.assignment.subject,
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vm.assignment.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${DateFormat('MMM d, y').format(vm.assignment.dueDate)}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.white10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
