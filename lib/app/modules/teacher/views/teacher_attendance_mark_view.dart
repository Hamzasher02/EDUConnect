import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_attendance_controller.dart';
import '../models/teacher_models.dart';
// Added for AttendanceStatus
import '../../../theme/app_colors.dart';

class TeacherAttendanceMarkView extends GetView<TeacherAttendanceController> {
  const TeacherAttendanceMarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedClass = controller.assignedClasses.firstWhereOrNull(
      (c) => c.id == controller.selectedClassId.value,
    );

    if (selectedClass == null) {
      Future.microtask(() => Get.back());
      return const Scaffold(backgroundColor: AppColors.primaryBlack);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
            Text(
              '${selectedClass.classNumber} - ${selectedClass.subjectName}',
              style: const TextStyle(color: AppColors.accentLime, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          // Offline Warning
          Obx(() {
            if (controller.isOffline.value) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent,
                child: const Text(
                  'Offline Mode: Cannot submit attendance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.studentsAttendance.length,
                itemBuilder: (context, index) {
                  final student = controller.studentsAttendance[index];
                  return Card(
                    color: AppColors.cardDark,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${student.name} (Roll: ${student.rollNo})',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusButton(
                                student,
                                AttendanceStatus.present,
                                'Present',
                                Colors.green,
                              ),
                              _buildStatusButton(
                                student,
                                AttendanceStatus.absent,
                                'Absent',
                                Colors.red,
                              ),
                              _buildStatusButton(
                                student,
                                AttendanceStatus.leave,
                                'Leave',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      (controller.isOffline.value ||
                          controller.alreadySubmittedToday.value)
                      ? null
                      : controller.submitAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    controller.alreadySubmittedToday.value
                        ? 'Submitted'
                        : 'Submit Attendance',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    StudentAttendanceModel student,
    AttendanceStatus status,
    String label,
    Color color,
  ) {
    // Note: In a real app we would use Obx here if model fields were reactive.
    // Since they are not reactive in model, we rely on parent Obx rebuilding list view on changes if controller list updates.
    // But typically we make status reactive or use a stateful widget.
    // For this mock with simple GetView, we force update via controller if needed.
    // Assuming parent Obx handles rebuild if we trigger update() in controller or use reactive list replacement.
    // But list elements usually need to be reactive themselves for fine-grained updates.
    // Given constraints, we will just use simple UI state for toggle visuals (or assume model status update + list refresh).
    // Since model is not reactive, we cannot standard Obx check status.
    // We will make local state or update UI naively. *Better: Use Stateful widget or GetBuilder for items.*
    // To strictly follow "Use GetX + Obx", we should have made status reactive in model.
    // As a workaround without changing model file (Step 2 constraint "Do NOT modify..."),
    // we'll assume the list refresh happens.

    bool isSelected = student.status == status;

    return InkWell(
      onTap: () {
        // Update status
        student.status = status;
        // Trigger UI update: Hacky way since model isn't reactive: refresh list
        controller.studentsAttendance.refresh();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
