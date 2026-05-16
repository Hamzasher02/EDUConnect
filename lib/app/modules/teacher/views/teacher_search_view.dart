import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/teacher_timetable_controller.dart';
import '../controllers/teacher_assignment_controller.dart';
import '../controllers/teacher_student_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

class TeacherSearchView extends GetView<TeacherController> {
  const TeacherSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlack,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Search students...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.accentLime,
            labelColor: AppColors.accentLime,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Timetable'),
              Tab(text: 'Assignments'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.white),
              onPressed: () => _showFilterSheet(context),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _StudentResultsList(),
            _TimetableResultsList(),
            _AssignmentResultsList(),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.resetFilters();
                    Get.back();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.accentLime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownFilter(
              label: 'Class',
              value: controller.filters.value.classId,
              items: controller.uniqueClassNames,
              onChanged: (val) {
                controller.updateFilters(
                  controller.filters.value.copyWith(classId: val),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter(
              label: 'Subject (Timetable)',
              value: controller.filters.value.subject,
              items: controller.uniqueSubjects,
              onChanged: (val) {
                controller.updateFilters(
                  controller.filters.value.copyWith(subject: val),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter(
              label: 'Day (Timetable)',
              value: controller.filters.value.day,
              items: controller.daysOfWeek,
              onChanged: (val) {
                controller.updateFilters(
                  controller.filters.value.copyWith(day: val),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Completion Status',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Obx(
                  () => FilterChip(
                    label: const Text('Completed'),
                    selected: controller.filters.value.completed == true,
                    onSelected: (val) {
                      controller.updateFilters(
                        controller.filters.value.copyWith(
                          completed: val ? true : null,
                        ),
                      );
                    },
                    selectedColor: AppColors.accentLime.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.accentLime,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => FilterChip(
                    label: const Text('Pending'),
                    selected: controller.filters.value.completed == false,
                    onSelected: (val) {
                      controller.updateFilters(
                        controller.filters.value.copyWith(
                          completed: val ? false : null,
                        ),
                      );
                    },
                    selectedColor: Colors.orange.withValues(alpha: 0.3),
                    checkmarkColor: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: AppColors.primaryBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: AppColors.cardDark,
              underline: const SizedBox.shrink(),
              hint: Text(
                'Select $label',
                style: const TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentResultsList extends GetView<TeacherController> {
  const _StudentResultsList();

  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<TeacherStudentController>();
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentLime),
        );
      }
      if (studentController.searchResults.isEmpty) {
        return const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'No Students Found',
          subtitle: 'Try a different search term or class filter',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: studentController.searchResults.length,
        itemBuilder: (context, index) {
          final student = studentController.searchResults[index];
          return Card(
            color: AppColors.cardDark,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, color: AppColors.accentLime),
              ),
              title: Text(
                student.name,
                style: const TextStyle(color: AppColors.white),
              ),
              subtitle: Text(
                'Roll: ${student.rollNo} • ${student.classNumber}',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
          );
        },
      );
    });
  }
}

class _TimetableResultsList extends GetView<TeacherController> {
  const _TimetableResultsList();

  @override
  Widget build(BuildContext context) {
    final timetableController = Get.find<TeacherTimetableController>();
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentLime),
        );
      }
      if (timetableController.filteredTimetable.isEmpty) {
        return const EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'No Schedule Found',
          subtitle: 'No classes match your current search/filter',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timetableController.filteredTimetable.length,
        itemBuilder: (context, index) {
          final slot = timetableController.filteredTimetable[index];
          return Card(
            color: AppColors.cardDark,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.day.substring(0, 3),
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              title: Text(
                slot.subjectName,
                style: const TextStyle(color: AppColors.white),
              ),
              subtitle: Text(
                'Class ${slot.classNumber} • ${slot.startTime} - ${slot.endTime}',
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: Text(
                'RM: ${slot.roomNumber}',
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          );
        },
      );
    });
  }
}

class _AssignmentResultsList extends GetView<TeacherController> {
  const _AssignmentResultsList();

  @override
  Widget build(BuildContext context) {
    final assignmentController = Get.find<TeacherAssignmentController>();
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentLime),
        );
      }
      if (assignmentController.filteredAssignments.isEmpty) {
        return const EmptyState(
          icon: Icons.assignment_late_outlined,
          title: 'No Assignments',
          subtitle: 'No assignments found matching your query',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignmentController.filteredAssignments.length,
        itemBuilder: (context, index) {
          final asn = assignmentController.filteredAssignments[index];
          final completed = asn.submissionCount == asn.totalStudents;
          return Card(
            color: AppColors.cardDark,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                asn.title,
                style: const TextStyle(color: AppColors.white),
              ),
              subtitle: Text(
                'Class ${asn.classNumber} • Submissions: ${asn.submissionCount}/${asn.totalStudents}',
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: Icon(
                completed ? Icons.check_circle : Icons.pending,
                color: completed ? AppColors.accentLime : Colors.orangeAccent,
              ),
            ),
          );
        },
      );
    });
  }
}
