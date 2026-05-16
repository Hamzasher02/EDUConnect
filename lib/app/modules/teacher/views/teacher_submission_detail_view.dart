import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_assignment_controller.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/submission_model.dart';
import '../../../theme/app_colors.dart';

class TeacherSubmissionDetailView extends GetView<TeacherAssignmentController> {
  final AssignmentModel assignment;

  const TeacherSubmissionDetailView({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Submissions: ${assignment.title}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentSubmissions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentSubmissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No submissions yet',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.currentSubmissions.length,
          itemBuilder: (context, index) {
            final submission = controller.currentSubmissions[index];
            return _buildSubmissionCard(context, submission);
          },
        );
      }),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    SubmissionModel submission,
  ) {
    final isGraded = submission.status == SubmissionStatus.graded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGraded
              ? AppColors.accentLime.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accentLime,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Submitted: ${_formatDate(submission.submittedAt)}',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isGraded
                        ? AppColors.accentLime
                        : Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isGraded
                        ? 'Graded: ${submission.marksObtained}/${assignment.maxMarks}'
                        : 'Pending',
                    style: TextStyle(
                      color: isGraded ? Colors.black : Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (submission.fileUrl != null &&
                submission.fileUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      color: AppColors.accentLime,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        submission.fileUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showGradingDialog(context, submission),
                  child: Text(
                    isGraded ? 'Re-Grade' : 'Review & Grade',
                    style: const TextStyle(color: AppColors.accentLime),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGradingDialog(BuildContext context, SubmissionModel submission) {
    final marksController = TextEditingController(
      text: submission.marksObtained?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Grade ${submission.studentName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Marks (out of ${assignment.maxMarks})',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Feedback for student...'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final m = double.tryParse(marksController.text);
              if (m == null) return;
              controller.gradeStudentSubmission(
                submissionId: submission.id,
                marks: m,
                feedback: feedbackController.text,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentLime,
            ),
            child: const Text(
              'Save Grade',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
