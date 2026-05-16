import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/student_timetable_controller.dart';
import '../controllers/student_exam_controller.dart';
import '../../school_admin/models/school_admin_models.dart';

class StudentTimetableView extends GetView<StudentTimetableController> {
  const StudentTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    final examController = Get.find<StudentExamController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Timetable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          _buildExamHighlights(examController),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.dailyClasses.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentLime),
                );
              }

              if (controller.dailyClasses.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshTimetable(),
                color: AppColors.accentLime,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.dailyClasses.length,
                  itemBuilder: (context, index) {
                    final slot = controller.dailyClasses[index];
                    return _buildClassCard(slot);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.weekDays.length,
        itemBuilder: (context, index) {
          final day = controller.weekDays[index];
          return Obx(() {
            final isSelected = controller.selectedDay.value == day;
            return GestureDetector(
              onTap: () => controller.loadDaySchedule(day),
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentLime : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentLime
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildClassCard(ClassTimetableSlotModel slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  slot.startTime,
                  style: const TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 12,
                  color: AppColors.accentLime,
                ),
                Text(
                  slot.endTime,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subjectName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      slot.teacherName,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                color: AppColors.accentLime,
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                'Room ${slot.roomNumber}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamHighlights(StudentExamController examController) {
    return Obx(() {
      final selectedDay = controller.selectedDay.value;
      // Map day names to actual dates in our mock (using tomorrow/next week pattern)
      // For simplicity in mock, we'll just check if any exam falls on the "calculated" date for this weekday.
      // But a better mock mapping:
      final now = DateTime.now();
      final currentWeekday = DateFormat('EEE').format(now);

      // Calculate date for the 'selectedDay' weekday
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final targetIndex = weekdays.indexOf(selectedDay);
      final currentIndex = weekdays.indexOf(currentWeekday);
      final diff = targetIndex - currentIndex;
      final targetDate = now.add(Duration(days: diff));

      final examsToday = examController.getExamsForDate(targetDate);
      if (examsToday.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: examsToday
              .map(
                (exam) => Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXAM ALERT: ${exam.subject}',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${exam.startTime} @ ${exam.location}',
                              style: TextStyle(
                                color: Colors.orangeAccent.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.studentExamDetail,
                          arguments: exam,
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            'No classes scheduled today',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
