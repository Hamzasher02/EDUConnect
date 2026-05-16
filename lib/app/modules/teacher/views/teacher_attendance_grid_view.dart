import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../controllers/attendance_grid_controller.dart';
import '../../../data/models/academic_attendance_model.dart';
import '../../../theme/app_colors.dart';

class TeacherAttendanceGridView extends GetView<AttendanceGridController> {
  const TeacherAttendanceGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Subject Attendance Grid',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildMonthNavigator(),
          Expanded(
            child: Obx(() {
              if (controller.selectedClass.isEmpty ||
                  controller.selectedSubject.isEmpty) {
                return _buildEmptyState(
                  'Select Class and Subject to view records',
                );
              }

              final g = controller.gridData.value;
              if (g == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentLime),
                );
              }

              if (g.rows.isEmpty) {
                return _buildEmptyState('No students found for this class');
              }

              return _buildAttendanceGrid(g);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: controller.prevMonth,
            icon: const Icon(Icons.chevron_left, color: AppColors.accentLime),
          ),
          Obx(() {
            final date = DateTime(
              controller.selectedYear.value,
              controller.selectedMonth.value,
            );
            return Text(
              DateFormat('MMMM yyyy').format(date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          }),
          IconButton(
            onPressed: controller.nextMonth,
            icon: const Icon(Icons.chevron_right, color: AppColors.accentLime),
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
            Icons.calendar_month_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildAttendanceGrid(AttendanceGridModel grid) {
    return Theme(
      data: Theme.of(
        Get.context!,
      ).copyWith(cardColor: AppColors.cardDark, dividerColor: Colors.white10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            horizontalMargin: 8,
            headingRowHeight: 50,
            dataRowMaxHeight: 50,
            headingRowColor: WidgetStateProperty.all(
              Colors.white.withValues(alpha: 0.02),
            ),
            columns: [
              const DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    'STUDENT',
                    style: TextStyle(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              ...grid.dates.map(
                (date) => DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 8,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: _isWeekend(date)
                              ? Colors.redAccent
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'PRESENT',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  '%',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            rows: grid.rows.map((row) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        row.studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () => _showAuditDialog(row),
                  ),
                  ...grid.dates.map((date) {
                    final record = row.dailyRecords[date.day]!;
                    return DataCell(
                      GestureDetector(
                        onTap: () => _showStatusPicker(
                          row.studentId,
                          row.studentName,
                          date.day,
                          record.status,
                        ),
                        child: _buildAttendanceBubble(record.status),
                      ),
                    );
                  }),
                  DataCell(
                    Center(
                      child: Text(
                        row.totalPresent.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${row.attendancePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: row.attendancePercentage < 75
                            ? Colors.redAccent
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showStatusPicker(
    String studentId,
    String studentName,
    int day,
    SubjectAttendanceStatus current,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark Attendance: $studentName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day $day of ${DateFormat('MMMM').format(DateTime(controller.selectedYear.value, controller.selectedMonth.value))}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildStatusItem(
              'Present',
              SubjectAttendanceStatus.present,
              AppColors.accentLime,
              Icons.check_circle_outline,
              studentId,
              day,
              current,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Absent',
              SubjectAttendanceStatus.absent,
              Colors.redAccent,
              Icons.highlight_off_rounded,
              studentId,
              day,
              current,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'On Leave',
              SubjectAttendanceStatus.leave,
              Colors.blueAccent,
              Icons.beach_access_rounded,
              studentId,
              day,
              current,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    SubjectAttendanceStatus status,
    Color color,
    IconData icon,
    String studentId,
    int day,
    SubjectAttendanceStatus current,
  ) {
    final isSelected = current == status;
    return InkWell(
      onTap: () {
        controller.setAttendanceStatus(studentId, day, status);
        Get.back();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBubble(SubjectAttendanceStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case SubjectAttendanceStatus.present:
        color = AppColors.accentLime;
        icon = Icons.check;
        break;
      case SubjectAttendanceStatus.absent:
        color = Colors.redAccent;
        icon = Icons.close;
        break;
      case SubjectAttendanceStatus.leave:
        color = Colors.blueAccent;
        icon = Icons.beach_access;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  void _showAuditDialog(StudentAttendanceRow row) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          row.studentName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildSummaryItem('Total Present', row.totalPresent.toString()),
              _buildSummaryItem(
                'Attendance %',
                '${row.attendancePercentage.toStringAsFixed(1)}%',
              ),
              const Divider(color: Colors.white10, height: 24),
              const Text(
                'RECENT CHANGES',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Flatten all history for this month
              ...row.dailyRecords.values
                  .where((r) => r.history.isNotEmpty)
                  .expand((r) => r.history.map((h) => MapEntry(r.date, h)))
                  .toList()
                  .sortedBy((e) => e.value.timestamp)
                  .reversed
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${DateFormat('d MMM').format(e.key)}: ${e.value.previousStatus.name} → ${e.value.newStatus.name} by ${e.value.teacherId.substring(0, 4)}... at ${DateFormat('HH:mm').format(e.value.timestamp)}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.accentLime),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
