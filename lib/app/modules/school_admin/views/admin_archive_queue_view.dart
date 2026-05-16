import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../../../routes/app_routes.dart';

class AdminArchiveQueueView extends GetView<SchoolAdminController> {
  const AdminArchiveQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Queue'),
        backgroundColor: AppColors.primaryBlack,
      ),
      body: Column(
        children: [
          // Offline Banner
          Obx(() {
            if (!controller.isOffline.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(12),
              // ignore: deprecated_member_use
              color: Colors.orange.withValues(alpha: 0.3),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode: Viewing only. Archive/Delete actions disabled.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Tabs
          Obx(() {
            return Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.archiveQueueTab.value = 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.archiveQueueTab.value == 0
                              ? AppColors.accentLime
                              : AppColors.cardDark,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Inactive Queue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.archiveQueueTab.value == 0
                                ? AppColors.cardDark
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.archiveQueueTab.value = 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.archiveQueueTab.value == 1
                              ? AppColors.accentLime
                              : AppColors.cardDark,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Archived',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.archiveQueueTab.value == 1
                                ? AppColors.cardDark
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Content
          Expanded(
            child: Obx(() {
              return controller.archiveQueueTab.value == 0
                  ? _buildInactiveQueue()
                  : _buildArchivedList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveQueue() {
    return Obx(() {
      final students = controller.inactiveQueueStudents;
      if (students.isEmpty) {
        return const Center(
          child: Text(
            'No inactive students',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return _buildInactiveCard(student);
        },
      );
    });
  }

  Widget _buildInactiveCard(StudentModel student) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.adminArchivedStudentDetail,
        arguments: {'student': student, 'isArchived': false},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roll: ${student.rollNo} | Class: ${student.classNumber}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (student.inactiveAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Inactive since: ${DateFormat('MMM dd, yyyy').format(student.inactiveAt!)}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'View Detail',
                      onPressed: () => Get.toNamed(
                        AppRoutes.adminArchivedStudentDetail,
                        arguments: {'student': student, 'isArchived': false},
                      ),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() {
                      return GlassButton(
                        text: 'Archive Now',
                        onPressed: controller.isOffline.value
                            ? null
                            : () => controller.archiveStudentNow(student.id),
                        isPrimary: true,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchivedList() {
    return Obx(() {
      final students = controller.archivedStudentsList;

      return Column(
        children: [
          // Run Retention Check button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              return SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Run Retention Check (5-Year)',
                  onPressed: controller.isOffline.value
                      ? null
                      : controller.checkAndAutoDeleteEligibleArchived,
                  isPrimary: false,
                ),
              );
            }),
          ),

          if (students.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No archived students',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildArchivedCard(student);
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _buildArchivedCard(StudentModel student) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.adminArchivedStudentDetail,
        arguments: {'student': student, 'isArchived': true},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Roll: ${student.rollNo} | Class: ${student.classNumber}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (student.deleteEligibleAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Delete Eligible On: ${DateFormat('MMM dd, yyyy').format(student.deleteEligibleAt!)}',
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'View Detail',
                      onPressed: () => Get.toNamed(
                        AppRoutes.adminArchivedStudentDetail,
                        arguments: {'student': student, 'isArchived': true},
                      ),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlassButton(
                      text: 'View Report',
                      onPressed: () {
                        // Check if report exists
                        if (!controller.studentSummaryReports.containsKey(
                          student.id,
                        )) {
                          controller.generateStudentSummaryReport(student);
                        }
                        Get.toNamed(
                          AppRoutes.adminArchiveReportDetail,
                          arguments: {
                            'isStudent': true,
                            'report':
                                controller.studentSummaryReports[student.id],
                          },
                        );
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
