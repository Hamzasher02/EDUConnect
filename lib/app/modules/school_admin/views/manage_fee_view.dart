import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart' as admin_models;
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class ManageFeeView extends GetView<SchoolAdminController> {
  const ManageFeeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.guardSelectedClass()) {
      Future.microtask(() => Get.back());
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(
          () => Text(
            'Fees: Class ${controller.selectedClass}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: Obx(() {
          final students =
              controller.studentsByClass[controller.selectedClass.value];
          if (students == null || students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.money_off_csred_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students in this class',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentFeeCard(student);
            },
          );
        }),
      ),
    );
  }

  Widget _buildStudentFeeCard(admin_models.StudentModel student) {
    final totalDues = controller.computeTotalDues(student.id);
    final hasDues = totalDues > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => controller.openStudentFeeDetails(student.id),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    (hasDues ? Colors.redAccent : AppColors.accentLime)
                        .withValues(alpha: 0.1),
                child: Text(
                  student.name[0],
                  style: TextStyle(
                    color: hasDues ? Colors.redAccent : AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll No: ${student.rollNo}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hasDues ? 'PKR ${totalDues.toInt()}' : 'Paid',
                    style: TextStyle(
                      color: hasDues ? Colors.redAccent : AppColors.accentLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (hasDues ? Colors.redAccent : AppColors.accentLime)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hasDues ? 'OUTSTANDING' : 'NO DUES',
                      style: TextStyle(
                        color: hasDues
                            ? Colors.redAccent
                            : AppColors.accentLime,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
