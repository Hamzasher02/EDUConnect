import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/teacher_controller.dart';
import '../../../theme/app_colors.dart';

class TeacherReportsView extends GetView<TeacherController> {
  const TeacherReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Reports & Exports',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLastExportInfo(),
                const SizedBox(height: 24),
                _buildSectionTitle('Available Reports'),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Class Timetable',
                  description:
                      'Export your scheduled classes and room assignments.',
                  format: 'CSV',
                  icon: Icons.calendar_today_outlined,
                  onExport: () => controller.exportTimetable(),
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Student Enrollment List',
                  description:
                      'Download the list of students for class management.',
                  format: 'CSV',
                  icon: Icons.people_outline,
                  hasClassSelector: true,
                  onExportWithClass: (classId) =>
                      controller.exportStudentList(classId),
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Analytics Performance Summary',
                  description:
                      'Summary of attendance, assignments, and student participation.',
                  format: 'PDF',
                  icon: Icons.analytics_outlined,
                  onExport: () => controller.exportAnalyticsReport(),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isExporting.value
                ? Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.accentLime,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Generating Report...',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLastExportInfo() {
    return Obx(() {
      final lastExport = controller.settings.value.lastExportTimestamp;
      final timeStr = lastExport != null
          ? DateFormat('MMM d, yyyy - hh:mm a').format(lastExport)
          : 'Never';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentLime.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: AppColors.accentLime),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Exported',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.accentLime,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required String format,
    required IconData icon,
    VoidCallback? onExport,
    Function(String)? onExportWithClass,
    bool hasClassSelector = false,
  }) {
    final selectedClass = ''.obs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: format == 'PDF'
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    color: format == 'PDF'
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (hasClassSelector) ...[
            const SizedBox(height: 16),
            Obx(
              () => DropdownButton<String>(
                hint: const Text(
                  'Select Class',
                  style: TextStyle(color: Colors.white54),
                ),
                value: selectedClass.value.isEmpty ? null : selectedClass.value,
                dropdownColor: AppColors.cardDark,
                isExpanded: true,
                underline: Container(height: 1, color: Colors.white24),
                style: const TextStyle(color: AppColors.white),
                items: controller.uniqueClassNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (val) => selectedClass.value = val ?? '',
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (hasClassSelector) {
                  if (selectedClass.value.isEmpty) {
                    Get.snackbar(
                      'Selection Required',
                      'Please select a class first',
                    );
                  } else {
                    onExportWithClass?.call(selectedClass.value);
                  }
                } else {
                  onExport?.call();
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Generate & Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentLime,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
