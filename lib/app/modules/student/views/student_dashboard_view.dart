import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../controllers/student_controller.dart';
import '../controllers/student_exam_controller.dart';
import '../models/student_models.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/glass_container.dart';
import 'student_attendance_view.dart';
import 'student_fee_view.dart';
import 'student_timetable_view.dart';
import 'student_exam_view.dart';
import 'student_result_view.dart';

class StudentDashboardView extends GetView<StudentController> {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: _buildAppBar(),
      body: Obx(() {
        switch (controller.currentTabIndex.value) {
          case 0:
            return _buildHomeTab();
          case 1:
            return const StudentFeeView();
          case 2:
            return const StudentAttendanceView();
          case 3:
            return const StudentTimetableView();
          case 4:
            return const StudentExamView();
          case 5:
            return const StudentResultView();
          default:
            return _buildHomeTab();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: AppColors.primaryBlack,
          currentIndex: controller.currentTabIndex.value,
          onTap: (index) => controller.currentTabIndex.value = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.accentLime,
          unselectedItemColor: Colors.white38,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Fee',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Timetable',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Exams',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Results',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.dashboardData.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentLime),
        );
      }

      final data = controller.dashboardData.value;
      if (data == null) {
        return const Center(
          child: Text(
            'Failed to load dashboard',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshDashboard(),
        color: AppColors.accentLime,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isOffline.value) _buildOfflineBanner(),
              const SizedBox(height: 16),
              _buildOverviewCard(data),
              const SizedBox(height: 24),
              _buildSubjectsSection(data),
              const SizedBox(height: 24),
              _buildUpcomingExamsSection(),
              const SizedBox(height: 24),
              _buildTodayClasses(data),
              const SizedBox(height: 24),
              _buildQuickStats(data),
              const SizedBox(height: 100), // Space for FAB/BottomNav
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubjectsSection(StudentDashboardData data) {
    if (data.subjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Subjects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.subjects.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final subject = data.subjects[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentLime.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentLime.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book,
                        color: AppColors.accentLime,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingExamsSection() {
    final examController = Get.find<StudentExamController>();
    return Obx(() {
      final exams = examController.exams;
      final nextExam = exams.isNotEmpty ? exams.first : null;
      
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.studentExams),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Examination Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (nextExam != null)
                      Text(
                        'Next: ${nextExam.subject} on ${DateFormat('MMM dd').format(nextExam.examDate)} at ${nextExam.startTime}',
                        style: TextStyle(
                          color: AppColors.accentLime.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        'No upcoming exams',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Dashboard',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.accentLime),
          onPressed: () => AuthService.to.logout(),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: const [
          Icon(Icons.offline_bolt_outlined, color: Colors.orange, size: 20),
          SizedBox(width: 12),
          Text(
            'Offline Mode - Reading cached data',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(StudentDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.accentLime.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.accentLime,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.className} | Section ${data.section}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(StudentDashboardData data) {
    return Row(
      children: [
        Expanded(child: _buildAttendanceCard(data)),
        const SizedBox(width: 16),
        Expanded(child: _buildAcademicCard(data)),
      ],
    );
  }

  Widget _buildAttendanceCard(StudentDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Attendance',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: data.attendancePercentage,
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentLime,
                ),
              ),
              Text(
                '${(data.attendancePercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.attendanceLabel,
            style: const TextStyle(
              color: AppColors.accentLime,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCard(StudentDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Academic Standing',
            style: TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentLime.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Text(
              data.overallPerformance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep it up!',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClasses(StudentDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Classes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (data.todaysClasses.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'No classes today',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ...data.todaysClasses.map((item) => _buildClassCard(item)),
      ],
    );
  }

  Widget _buildClassCard(StudentClassItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  item.startTime,
                  style: const TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 12,
                  color: AppColors.accentLime,
                ),
                Text(
                  item.endTime,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                  item.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Teacher: ${item.teacherName}',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                color: Colors.white38,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                item.room,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
