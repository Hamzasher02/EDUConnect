import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../models/exam_models.dart';
import '../../../widgets/glass_container.dart';

class StudentExamDetailView extends StatelessWidget {
  const StudentExamDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null || Get.arguments is! StudentExamModel) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text(
            'Exam details not found.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    final StudentExamModel exam = Get.arguments;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Exam Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(exam),
            const SizedBox(height: 32),
            _buildInfoCard('Date & Time', [
              _buildInfoRow(
                Icons.calendar_today,
                DateFormat('EEEE, MMM dd, yyyy').format(exam.examDate),
              ),
              _buildInfoRow(
                Icons.access_time,
                '${exam.startTime} - ${exam.endTime}',
              ),
            ]),
            const SizedBox(height: 24),
            _buildInfoCard('Venue & Supervision', [
              _buildInfoRow(
                Icons.location_on_outlined,
                exam.location ?? 'Examination Hall',
              ),
              _buildInfoRow(
                Icons.person_outline,
                'Invigilator: ${exam.teacherName ?? "TBD"}',
              ),
            ]),
            const SizedBox(height: 24),
            if (exam.instructions != null)
              _buildInfoCard('Instructions', [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    exam.instructions!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ], isInstruction: true),
            const SizedBox(height: 40),
            _buildPreparationAlert(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(StudentExamModel exam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentLime.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            exam.examType.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accentLime,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          exam.subject,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          exam.examName,
          style: const TextStyle(color: Colors.white38, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    List<Widget> children, {
    bool isInstruction = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLime, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orangeAccent, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Please reach the venue 15 minutes before the start time.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
