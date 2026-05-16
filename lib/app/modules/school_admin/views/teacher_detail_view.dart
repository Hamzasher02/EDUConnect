import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class TeacherDetailView extends GetView<SchoolAdminController> {
  const TeacherDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final String? teacherId = Get.arguments?.toString();

    if (teacherId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No teacher selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final teacher = controller.teachers.firstWhereOrNull(
      (t) => t.id == teacherId,
    );

    if (teacher == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Teacher not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // assigned classes for this teacher (Timetable)
    final allSlots = controller.base.schoolDataService.getTimetable(
      controller.base.currentSchoolId,
    );
    final assignedSlots = allSlots
        .where((s) => s.teacherId == teacherId)
        .toList();

    // Formal assignments from admin
    final formalAssignments = controller.base.schoolDataService
        .getTeacherAssignmentsBySchool(controller.base.currentSchoolId)
        .where((a) => a.teacherId == teacherId)
        .toList();

    // Unique classes from both sources
    final classes = {
      ...assignedSlots.map((s) => s.classNumber),
      ...formalAssignments.map((a) => a.classNumber),
    }.toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          teacher.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, teacher),
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.edit, color: AppColors.primaryBlack),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeacherHeader(teacher),
              const SizedBox(height: 24),
              _buildInfoSection(teacher),
              const SizedBox(height: 24),
              const Text(
                'Assigned Classes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (assignedSlots.isEmpty)
                const Text(
                  'No classes assigned',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assignedSlots.length,
                  itemBuilder: (context, index) {
                    final slot = assignedSlots[index];
                    return _buildClassCard(slot);
                  },
                ),
              const SizedBox(height: 24),
              const Text(
                'Formal Assignments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (formalAssignments.isEmpty)
                const Text(
                  'No formal assignments',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: formalAssignments.length,
                  itemBuilder: (context, index) {
                    final assignment = formalAssignments[index];
                    return _buildFormalAssignmentCard(assignment);
                  },
                ),
              const SizedBox(height: 24),
              const Text(
                'Students in Classes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (var classNum in classes) _buildStudentListForClass(classNum),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherHeader(TeacherModel teacher) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accentLime.withValues(alpha: 0.1),
            child: Text(
              teacher.name[0],
              style: const TextStyle(
                color: AppColors.accentLime,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  teacher.subjectSpecialization,
                  style: TextStyle(
                    color: AppColors.accentLime.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    teacher.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(TeacherModel teacher) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', teacher.email),
          _buildDivider(),
          _buildInfoRow(
            Icons.lock_outline,
            'Password',
            teacher.password ?? 'Not set',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.phone_android_outlined,
            'Contact',
            teacher.contactNumber,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.school_outlined,
            'Qualification',
            teacher.qualification,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.history_outlined,
            'Experience',
            '${teacher.experienceYears} Years',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLime, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white24,
              size: 18,
            ),
            onPressed: () {
              // TODO: Implement update
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.05), height: 16);
  }

  Widget _buildFormalAssignmentCard(TeacherAssignmentModel assignment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_ind_outlined,
                color: AppColors.accentLime,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${assignment.subjectName} - Class ${assignment.classNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Formal Assignment',
                    style: TextStyle(
                      color: AppColors.accentLime.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Remove Assignment?',
                  middleText: 'Are you sure you want to remove this formal assignment?',
                  textConfirm: 'Remove',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.redAccent,
                  onConfirm: () {
                    controller.removeFormalAssignment(assignment.id);
                    Get.back();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassTimetableSlotModel slot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showEditSlotSheet(slot),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: AppColors.accentLime,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.subjectName} - Class ${slot.classNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${slot.day} • ${slot.startTime} - ${slot.endTime} • Room ${slot.roomNumber}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSlotSheet(ClassTimetableSlotModel slot) {
    final subjectController = TextEditingController(text: slot.subjectName);
    final roomController = TextEditingController(text: slot.roomNumber);
    final startController = TextEditingController(text: slot.startTime);
    final endController = TextEditingController(text: slot.endTime);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Class Slot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    Get.back();
                    Get.defaultDialog(
                      title: 'Delete Slot?',
                      middleText:
                          'Are you sure you want to remove this class slot?',
                      textConfirm: 'Delete',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      onConfirm: () {
                        controller.removeTimetableSlot(slot.id);
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.book_outlined, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roomController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Room Number',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.room_outlined, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final subjects = controller.getSubjectsForClass(
                    slot.classNumber,
                  );
                  final subjectObj = subjects.firstWhereOrNull(
                    (s) => s.name == subjectController.text,
                  );

                  controller.updateTimetableSlot(
                    slotId: slot.id,
                    subjectId: subjectObj?.id ?? subjectController.text,
                    subjectName: subjectController.text,
                    teacherId: slot.teacherId ?? '',
                    teacherName: slot.teacherName,
                    start: startController.text,
                    end: endController.text,
                    room: roomController.text,
                    classNumber: slot.classNumber,
                    day: slot.day,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Update Slot',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStudentListForClass(String classNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Class $classNumber Students',
            style: const TextStyle(
              color: AppColors.accentLime,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          final students = controller.base.schoolDataService.getStudentsByClass(
            controller.base.currentSchoolId,
            classNumber,
          );

          if (students.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 16),
              child: Text(
                'No students in this class',
                style: TextStyle(color: Colors.white24),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white10,
                  child: Text(
                    student.name[0],
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                title: Text(
                  student.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                subtitle: Text(
                  'Roll: ${student.rollNo}',
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showEditDialog(BuildContext context, TeacherModel teacher) {
    final nameCtrl = TextEditingController(text: teacher.name);
    final emailCtrl = TextEditingController(text: teacher.email);
    final qualCtrl = TextEditingController(text: teacher.qualification);
    final subjCtrl = TextEditingController(text: teacher.subjectSpecialization);
    final contactCtrl = TextEditingController(text: teacher.contactNumber);

    Get.defaultDialog(
      title: 'Edit Teacher',
      titleStyle: const TextStyle(color: AppColors.accentLime),
      backgroundColor: AppColors.cardDark,
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: qualCtrl,
              decoration: const InputDecoration(labelText: 'Qualification'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: subjCtrl,
              decoration: const InputDecoration(labelText: 'Specialization'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: contactCtrl,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.primaryBlack,
      buttonColor: AppColors.accentLime,
      onConfirm: () async {
        try {
          final updatedTeacher = teacher.copyWith(
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            qualification: qualCtrl.text.trim(),
            subjectSpecialization: subjCtrl.text.trim(),
            contactNumber: contactCtrl.text.trim(),
          );

          await controller.base.schoolDataService.addTeacher(
            teacher.schoolId,
            updatedTeacher,
          );

          Get.back(); // close dialog
          Get.snackbar('Success', 'Profile updated successfully');
          Get.off(
            () => const TeacherDetailView(),
            arguments: teacher.id,
            preventDuplicates: false,
          );
        } catch (e) {
          Get.defaultDialog(title: 'Error', middleText: e.toString());
        }
      },
    );
  }
}
