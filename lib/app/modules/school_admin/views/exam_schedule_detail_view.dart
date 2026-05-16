import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';

class ExamScheduleDetailView extends GetView<SchoolAdminController> {
  const ExamScheduleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final classNumber = args['classNumber'] as String?;

    if (classNumber == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text(
            'No class specified',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedule — $classNumber'),
        backgroundColor: AppColors.primaryBlack,
      ),
      body: Obx(() {
        final schedule = controller.examSchedulesByClass[classNumber];

        if (schedule == null) {
          return const Center(
            child: Text(
              'No exam schedule found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final isLocked = schedule.isLocked;
        final isOffline = controller.isOffline.value;

        return Column(
          children: [
            // Offline Banner
            if (isOffline)
              Container(
                padding: const EdgeInsets.all(12),
                // ignore: deprecated_member_use
color: Colors.orange.withValues(alpha: 0.3),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Mode: Viewing only',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              // ignore: deprecated_member_use
color: AppColors.primaryBlack.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Academic Year: ${schedule.academicYear}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isLocked ? 'LOCKED' : 'EDITABLE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(schedule.createdAt)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Subject List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedule.subjects.length,
                itemBuilder: (context, index) {
                  final subject = schedule.subjects[index];
                  return _buildSubjectCard(context, subject, index + 1);
                },
              ),
            ),

            // Edit Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Edit Schedule',
                  onPressed: (isLocked || isOffline)
                      ? null
                      : () {
                          controller.goToScheduleExam(classNumber);
                        },
                  isPrimary: true,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubjectCard(BuildContext context, dynamic subject, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Number badge
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.accentLime,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Subject info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(subject.examDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.examTime.format(context),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


