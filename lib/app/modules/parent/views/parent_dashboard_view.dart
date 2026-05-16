import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parent_controller.dart';
import '../../../data/models/student_model.dart';
import '../../../routes/app_routes.dart';

/// Parent Dashboard View - Main parent screen showing student overview
class ParentDashboardView extends GetView<ParentController> {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(() {
          final student = controller.selectedStudent.value;
          return Text(student != null ? student.name : 'Dashboard');
        }),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Student switcher button (if multiple students)
          Obx(() {
            if (controller.linkedStudents.length > 1) {
              return IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Switch Student',
                onPressed: () {
                  Get.toNamed(AppRoutes.parentSelectStudent);
                },
              );
            }
            return const SizedBox.shrink();
          }),

          // Profile button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.toNamed(AppRoutes.parentProfile);
            },
          ),
        ],
      ),
      body: Obx(() {
        final student = controller.selectedStudent.value;

        if (student == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info Card
                _buildStudentInfoCard(student),
                const SizedBox(height: 20),

                // Quick Actions Grid - REMOVED (Unifying with Student Dashboard)
                // When a student is selected, we auto-navigate to StudentDashboard.
                // This view now serves as a fallback or selection screen.
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.touch_app, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        'Tap "Switch Student" or select a student to view their dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.selectStudent(student);
                        },
                        icon: const Icon(Icons.dashboard),
                        label: const Text('Go to Student Dashboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStudentInfoCard(StudentModel student) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 35,
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class ${student.classNumber} • ${student.rollNo}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
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
}
