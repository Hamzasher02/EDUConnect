import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/teacher_student_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/academic_attendance_model.dart' as academic;

class TeacherStudentsView extends GetView<TeacherController> {
  const TeacherStudentsView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<TeacherStudentController>();
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'My Students',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context, studentController),
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.person_add, color: AppColors.primaryBlack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Class Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() {
                final classes = controller.uniqueClassNames;
                if (classes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No classes assigned',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                // Ensure selected value is valid
                var selected = studentController.selectedStudentClass.value;
                if (!classes.contains(selected) && classes.isNotEmpty) {
                  // Auto-select first if current selection is invalid
                  selected = classes.first;
                  // Defer update to avoid build error
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    studentController.fetchStudents(selected);
                  });
                }

                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: classes.contains(selected) ? selected : null,
                    hint: const Text(
                      'Select Class',
                      style: TextStyle(color: Colors.white54),
                    ),
                    dropdownColor: AppColors.cardDark,
                    isExpanded: true,
                    style: const TextStyle(color: AppColors.white),
                    items: classes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Class $value'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        studentController.fetchStudents(newValue);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Student List
            Expanded(
              child: Obx(() {
                if (studentController.selectedStudentClass.value.isEmpty) {
                  return const Center(
                    child: Text(
                      'Please select a class',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                if (studentController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentLime,
                    ),
                  );
                }

                final students = studentController.studentsForSelectedClass;
                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students found in this class',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      color: AppColors.cardDark,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _showAttendanceSheet(context, studentController, student),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryBlack,
                          child: Icon(
                            Icons.person,
                            color: AppColors.accentLime,
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(color: AppColors.white),
                        ),
                        subtitle: Text(
                          'Roll No: ${student.rollNo} • Tap to mark attendance',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        trailing: const Icon(
                          Icons.how_to_reg_outlined,
                          color: AppColors.accentLime,
                          size: 18,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceSheet(
    BuildContext context,
    TeacherStudentController controller,
    StudentModel student,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mark Attendance: ${student.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOption(
              icon: Icons.check_circle_outline,
              label: 'Present',
              color: Colors.green,
              onTap: () {
                controller.markAttendanceAccordingToTimetable(
                  student,
                  status: academic.SubjectAttendanceStatus.present,
                );
                Get.back();
              },
            ),
            _buildOption(
              icon: Icons.exit_to_app_outlined,
              label: 'Leave',
              color: Colors.orange,
              onTap: () {
                controller.markAttendanceAccordingToTimetable(
                  student,
                  status: academic.SubjectAttendanceStatus.leave,
                );
                Get.back();
              },
            ),
            _buildOption(
              icon: Icons.cancel_outlined,
              label: 'Absent',
              color: Colors.red,
              onTap: () {
                controller.markAttendanceAccordingToTimetable(
                  student,
                  status: academic.SubjectAttendanceStatus.absent,
                );
                Get.back();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  void _showAddStudentDialog(
    BuildContext context,
    TeacherStudentController studentController,
  ) {
    final nameController = TextEditingController();
    final rollNoController = TextEditingController();

    Get.defaultDialog(
      title: 'Add Student',
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Student Name'),
          ),
          TextField(
            controller: rollNoController,
            decoration: const InputDecoration(labelText: 'Roll Number'),
          ),
        ],
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (nameController.text.isEmpty || rollNoController.text.isEmpty) {
          Get.snackbar('Error', 'Please fill all fields');
          return;
        }
        studentController.addStudent(
          nameController.text,
          rollNoController.text,
        );
      },
    );
  }
}
