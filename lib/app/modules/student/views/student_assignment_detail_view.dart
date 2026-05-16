import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_assignment_controller.dart';
import '../models/assignment_models.dart';

import 'student_assignment_submit_view.dart';

class StudentAssignmentDetailView extends GetView<StudentAssignmentController> {
  const StudentAssignmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Detail', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        final vm = controller.selectedAssignment.value;
        if (vm == null) return const SizedBox();

        final status = vm.calculatedStatus;
        final isSubmitted =
            status == SubmissionStatus.submitted ||
            status == SubmissionStatus.graded;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(vm),
                    const SizedBox(height: 32),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.assignment.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (vm.assignment.attachmentUrl != null)
                      _buildAttachmentPreview(),
                    if (isSubmitted) _buildSubmissionInfo(vm),
                  ],
                ),
              ),
            ),
            if (!isSubmitted) _buildSubmitSection(vm),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(StudentAssignmentViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              vm.assignment.subject,
              style: const TextStyle(
                color: AppColors.accentLime,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildStatusBadge(vm.calculatedStatus),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          vm.assignment.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white38, size: 16),
            const SizedBox(width: 8),
            Text(
              'Deadline: ${DateFormat('MMM d, y • hh:mm a').format(vm.assignment.dueDate)}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(SubmissionStatus status) {
    Color color;
    String text;
    switch (status) {
      case SubmissionStatus.submitted:
        color = Colors.greenAccent;
        text = 'SUBMITTED';
        break;
      case SubmissionStatus.late:
        color = Colors.redAccent;
        text = 'LATE';
        break;
      case SubmissionStatus.graded:
        color = AppColors.accentLime;
        text = 'GRADED';
        break;
      case SubmissionStatus.notSubmitted:
        color = Colors.orangeAccent;
        text = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Assignment_Brief.pdf',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white38),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionInfo(StudentAssignmentViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Successfully Submitted',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            'Date',
            DateFormat(
              'MMM d, y • hh:mm a',
            ).format(vm.submission!.submittedAt!),
          ),
          const SizedBox(height: 8),
          _infoRow(
            'File',
            vm.submission!.submittedFileUrl?.split('/').last ?? 'Unknown',
          ),
          if (vm.submission?.status == SubmissionStatus.graded) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            const Text(
              'Teacher Grade & Feedback',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marks Obtained:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '${vm.submission!.marksObtained} / ${vm.assignment.id.isEmpty ? "?" : "10"}', // Ideally from assignment model
                        style: const TextStyle(
                          color: AppColors.accentLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (vm.submission?.teacherFeedback != null &&
                      vm.submission!.teacherFeedback!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Feedback:',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.submission!.teacherFeedback!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSubmitSection(StudentAssignmentViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.isOffline.value) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white38, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Submission disabled offline',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isOffline.value
                    ? null
                    : () => Get.to(() => const StudentAssignmentSubmitView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
                child: const Text(
                  'GO TO SUBMISSION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
