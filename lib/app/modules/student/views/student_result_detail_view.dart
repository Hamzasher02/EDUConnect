import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_result_controller.dart';
import '../models/result_models.dart';
import '../../../utils/grade_utils.dart';

class StudentResultDetailView extends GetView<StudentResultController> {
  const StudentResultDetailView({super.key});

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
        title: const Text('Exam Detail', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        final summary = controller.selectedExam.value;
        if (summary == null) return const SizedBox();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(summary),
              const SizedBox(height: 32),
              const Text(
                'Subject Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildResultsTable(summary),
              const SizedBox(height: 32),
              _buildOverviewCard(summary),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryHeader(ExamSummaryModel summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.examName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                GradeUtility.getPerformanceLabel(summary.percentage),
                style: const TextStyle(
                  color: AppColors.accentLime,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Academic Year 2025',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsTable(ExamSummaryModel summary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          _buildTableHeader(),
          ...summary.subjectResults.map((res) => _buildTableRow(res)),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      children: const [
        _TableCell('Subject', isHeader: true),
        _TableCell('Obt.', isHeader: true),
        _TableCell('Total', isHeader: true),
        _TableCell('%', isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(StudentResultModel res) {
    return TableRow(
      children: [
        _TableCell(res.subject),
        _TableCell(res.obtainedMarks.toString()),
        _TableCell(res.totalMarks.toInt().toString()),
        _TableCell('${res.percentage.toInt()}%', color: AppColors.accentLime),
      ],
    );
  }

  Widget _buildOverviewCard(ExamSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentLime.withValues(alpha: 0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Aggregate Marks',
            '${summary.totalObtained} / ${summary.totalPossible}',
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Overall Percentage',
            '${summary.percentage.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Calculated GPA',
            GradeUtility.getGPA(summary.percentage).toStringAsFixed(1),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Final Grade',
            GradeUtility.getGrade(summary.percentage),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Class Rank',
            summary.rank != null
                ? '${summary.rank} of ${summary.totalStudents}'
                : 'N/A',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final Color? color;

  const _TableCell(this.text, {this.isHeader = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isHeader ? Colors.white38 : Colors.white70),
          fontSize: isHeader ? 12 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
