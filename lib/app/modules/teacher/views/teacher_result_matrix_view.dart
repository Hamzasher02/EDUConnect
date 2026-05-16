import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/result_matrix_controller.dart';
import '../../../data/models/academic_result_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../theme/app_colors.dart';

class TeacherResultMatrixView extends GetView<ResultMatrixController> {
  const TeacherResultMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Academic Result Matrix',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.selectedClass.isEmpty ||
                  controller.selectedSubject.isEmpty) {
                return _buildEmptyState(
                  'Select Class and Subject to view records',
                );
              }

              final m = controller.matrix.value;
              if (m == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentLime),
                );
              }

              if (m.rows.isEmpty) {
                return _buildEmptyState('No students found for this class');
              }

              return _buildMatrixGrid(m);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _buildDropdown(
                'Class',
                controller.selectedClass.value,
                controller.assignedClasses,
                (val) => controller.selectedClass.value = val!,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => _buildDropdown(
                'Subject',
                controller.selectedSubject.value,
                controller.assignedSubjects,
                (val) => controller.selectedSubject.value = val!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value.isNotEmpty && items.contains(value)) ? value : null,
              hint: const Text(
                'Select',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardDark,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.accentLime,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_on_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildMatrixGrid(ResultMatrixModel matrix) {
    return Theme(
      data: Theme.of(
        Get.context!,
      ).copyWith(cardColor: AppColors.cardDark, dividerColor: Colors.white10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 16,
            headingRowColor: WidgetStateProperty.all(
              Colors.white.withValues(alpha: 0.03),
            ),
            dataRowMaxHeight: 60,
            columns: [
              const DataColumn(
                label: Text(
                  'Student Name',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...matrix.columns.map(
                (col) => DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        col.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Max: ${col.maxMarks}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Total %',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Grade',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            rows: matrix.rows.map((row) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      row.studentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _showStudentDetail(row),
                  ),
                  ...matrix.columns.map((col) {
                    final res = row.results[col.id]!;
                    return DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Text(
                          res.marksObtained.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _showEditDialog(
                        row.studentId,
                        row.studentName,
                        col.id,
                        col.name,
                        res,
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      '${row.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  DataCell(_buildGradeBadge(row.grade)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeBadge(String grade) {
    final color = _getGradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.contains('A')) return AppColors.accentLime;
    if (grade.contains('B')) return Colors.blueAccent;
    if (grade.contains('C')) return Colors.orangeAccent;
    if (grade.contains('D')) return Colors.deepOrangeAccent;
    return Colors.redAccent;
  }

  void _showEditDialog(
    String studentId,
    String studentName,
    String assessmentId,
    String assessmentName,
    AcademicResultModel result,
  ) {
    final textController = TextEditingController(
      text: result.marksObtained.toString(),
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Marks: $studentName',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assessment: $assessmentName',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Max Marks: ${result.maxMarks}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Marks Obtained',
                labelStyle: const TextStyle(color: AppColors.accentLime),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
              final val = double.tryParse(textController.text);
              if (val != null) {
                controller.updateMarks(studentId, assessmentId, val);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentLime,
              foregroundColor: Colors.black,
            ),
            child: const Text('Record Grade'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(StudentResultRow row) {
    Get.to(
      () => Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(
          title: Text(
            row.studentName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(
              'Overall Percentage',
              '${row.percentage.toStringAsFixed(1)}%',
              AppColors.accentLime,
            ),
            _buildStatCard(
              'Predicted Grade',
              row.grade,
              _getGradeColor(row.grade),
            ),
            const SizedBox(height: 24),
            const Text(
              'Assessment Breakdown',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...row.results.values.map(
              (res) => Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    res.assessmentName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip(res.category),
                                ],
                              ),
                              Text(
                                'Last updated: ${_formatDate(res.updatedAt)}',
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${res.marksObtained} / ${res.maxMarks}',
                          style: const TextStyle(
                            color: AppColors.accentLime,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (res.history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HISTORY',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 8,
                            ),
                          ),
                          ...res.history.reversed.map(
                            (h) => Text(
                              '• ${h.previousValue} → ${h.newValue} by ${h.teacherId.substring(0, 4)}... at ${_formatDate(h.timestamp)}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(AssessmentCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: const TextStyle(color: Colors.white38, fontSize: 8),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
