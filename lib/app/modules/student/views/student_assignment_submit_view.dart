import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_assignment_controller.dart';
import '../models/assignment_models.dart';

class StudentAssignmentSubmitView extends StatefulWidget {
  const StudentAssignmentSubmitView({super.key});

  @override
  State<StudentAssignmentSubmitView> createState() =>
      _StudentAssignmentSubmitViewState();
}

class _StudentAssignmentSubmitViewState
    extends State<StudentAssignmentSubmitView> {
  final controller = Get.find<StudentAssignmentController>();
  final _commentController = TextEditingController();
  String? _selectedFilePath;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = controller.selectedAssignment.value;
    if (vm == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Submit Assignment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssignmentSummary(vm),
            const SizedBox(height: 32),
            _buildLabel('Attach File'),
            const SizedBox(height: 12),
            _buildFilePicker(),
            const SizedBox(height: 32),
            _buildLabel('Comments (Optional)'),
            const SizedBox(height: 12),
            _buildCommentField(),
            const SizedBox(height: 48),
            Obx(() => _buildSubmitButton(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentSummary(StudentAssignmentViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.accentLime,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.assignment.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  vm.assignment.subject,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: () async {
        final vm = controller.selectedAssignment.value;
        if (vm == null) return;

        final url = await controller.pickAndUploadFile(vm.assignment.id);
        if (url != null) {
          setState(() {
            _selectedFilePath = url;
          });
          Get.snackbar('Success', 'File uploaded and ready for submission');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFilePath != null
                ? AppColors.accentLime
                : Colors.white10,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFilePath != null
                  ? (_selectedFilePath!.toLowerCase().contains('.pdf')
                        ? Icons.picture_as_pdf
                        : Icons.image)
                  : Icons.cloud_upload_outlined,
              color: _selectedFilePath != null
                  ? AppColors.accentLime
                  : Colors.white38,
              size: 40,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _selectedFilePath != null
                    ? (_selectedFilePath!.split('/').last.split('?').first)
                    : 'Tap to select PDF or Image',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _selectedFilePath != null
                      ? Colors.white
                      : Colors.white38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Add a message for your teacher...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(StudentAssignmentViewModel vm) {
    final isLoading = controller.isLoading.value;
    final isDisabled = _selectedFilePath == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                controller.submitAssignment(
                  vm.assignment.id,
                  _selectedFilePath!,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentLime,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'SUBMIT NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
