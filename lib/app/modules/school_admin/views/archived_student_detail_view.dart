import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../../../routes/app_routes.dart';

class ArchivedStudentDetailView extends GetView<SchoolAdminController> {
  const ArchivedStudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final student = args['student'];
    final isArchived = args['isArchived'] ?? false;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text(
            'No student data available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArchived ? 'Archived Student' : 'Inactive Student'),
        backgroundColor: AppColors.cardDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Student Photo Placeholder
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.accentLime,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.cardDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Roll: ${student.rollNo} | Class: ${student.classNumber}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lifecycle Timeline
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lifecycle Timeline',
                    style: TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  _buildTimelineItem(
                    'Active',
                    'Student enrolled',
                    status: 'completed',
                  ),
                  if (student.inactiveAt != null)
                    _buildTimelineItem(
                      'Inactive',
                      DateFormat('MMM dd, yyyy').format(student.inactiveAt),
                      status: 'completed',
                    ),
                  if (student.archivedAt != null)
                    _buildTimelineItem(
                      'Archived',
                      DateFormat('MMM dd, yyyy').format(student.archivedAt),
                      status: 'completed',
                    ),
                  if (student.deleteEligibleAt != null)
                    _buildTimelineItem(
                      'Delete Eligible',
                      DateFormat(
                        'MMM dd, yyyy',
                      ).format(student.deleteEligibleAt),
                      status: 'pending',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            if (!isArchived)
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    text: 'Archive Student Now',
                    onPressed: controller.isOffline.value
                        ? null
                        : () {
                            controller.archiveStudentNow(student.id);
                            Get.back();
                          },
                    isPrimary: true,
                  ),
                );
              })
            else
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'View Summary Report',
                  onPressed: () {
                    if (!controller.studentSummaryReports.containsKey(
                      student.id,
                    )) {
                      controller.generateStudentSummaryReport(student);
                    }
                    Get.toNamed(
                      AppRoutes.adminArchiveReportDetail,
                      arguments: {
                        'isStudent': true,
                        'report': controller.studentSummaryReports[student.id],
                      },
                    );
                  },
                  isPrimary: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle, {
    String status = 'pending',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            status == 'completed'
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: status == 'completed'
                ? AppColors.accentLime
                : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
