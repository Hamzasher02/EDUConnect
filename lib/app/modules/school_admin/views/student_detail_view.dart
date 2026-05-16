import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/result_model.dart';
import '../../../services/school_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../controllers/admin_student_controller.dart';

class StudentDetailView extends StatelessWidget {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Expect StudentModel to be passed as argument
    if (Get.arguments == null || Get.arguments is! StudentModel) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: No student data found.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    final StudentModel student = Get.arguments as StudentModel;
    final SchoolDataService dataService = Get.find<SchoolDataService>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, student, dataService),
        backgroundColor: AppColors.accentLime,
        child: const Icon(Icons.edit, color: AppColors.primaryBlack),
      ),
      body: Container(
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
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.accentLime.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        student.name[0],
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppColors.accentLime,
                          fontWeight: FontWeight.bold,
                        ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentLime.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Class ${student.classNumber} | Roll No: ${student.rollNo}',
                        style: const TextStyle(
                          color: AppColors.accentLime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSection('Student Credentials'),
              const SizedBox(height: 16),
              _buildInfoTile('Email (Login)', student.email ?? 'Not set'),
              _buildInfoTile(
                'Password',
                student.password ?? 'Not set',
                isSensitive: true,
              ),

              const SizedBox(height: 24),
              _buildSection('Academic Performance (Marks)'),
              const SizedBox(height: 16),
              FutureBuilder<List<ResultModel>>(
                future: Future.value(dataService.getStudentResults(student.id)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error loading marks: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  }
                  final results = snapshot.data ?? [];
                  if (results.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No marks recorded yet.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: results
                        .map((res) => _buildResultTile(res))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              _buildSection('Parent / Guardian Info'),
              const SizedBox(height: 16),
              _buildInfoTile('Parent Email', student.parentEmail),
              _buildInfoTile('Parent CNIC', student.parentCnic),
              _buildInfoTile('Contact Number', student.contactNumber ?? 'N/A'),
              _buildInfoTile('Home Address', student.address ?? 'N/A'),

              const SizedBox(height: 24),
              _buildSection('Academic Info'),
              const SizedBox(height: 16),
              _buildInfoTile(
                'Admission Date',
                student.admissionDate?.toString().split(' ')[0] ?? 'N/A',
              ),
              _buildInfoTile(
                'Status',
                student.isStruckOff ? 'Struck Off' : 'Active',
                valueColor: student.isStruckOff
                    ? Colors.redAccent
                    : Colors.greenAccent,
              ),

              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Login Access',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Allow student to login to their portal',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Switch(
                          value: student.canStudentLogin,
                          activeColor: AppColors.accentLime,
                          onChanged: (val) async {
                            final controller =
                                Get.find<AdminStudentController>();
                            await controller.toggleStudentAccess(student);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile(ResultModel res) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    res.examName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
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
                  '${res.marksObtained} / ${res.totalMarks}',
                  style: const TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Grade: ${res.grade}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.accentLime,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value, {
    bool isSensitive = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SelectableText(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSensitive)
              const Icon(Icons.copy, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StudentModel student,
    SchoolDataService dataService,
  ) {
    final nameCtrl = TextEditingController(text: student.name);
    final rollCtrl = TextEditingController(text: student.rollNo);
    final passCtrl = TextEditingController(text: student.password ?? '');
    final cnicCtrl = TextEditingController(text: student.parentCnic);
    final parentEmailCtrl = TextEditingController(text: student.parentEmail);
    final contactCtrl = TextEditingController(
      text: student.contactNumber ?? '',
    );
    final addressCtrl = TextEditingController(text: student.address ?? '');

    Get.defaultDialog(
      title: 'Edit Student',
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
              controller: rollCtrl,
              decoration: const InputDecoration(labelText: 'Roll No'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: cnicCtrl,
              decoration: const InputDecoration(labelText: 'Parent CNIC'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: parentEmailCtrl,
              decoration: const InputDecoration(labelText: 'Parent Email'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: contactCtrl,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
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
          final updatedStudent = StudentModel(
            id: student.id,
            schoolId: student.schoolId,
            name: nameCtrl.text.trim(),
            rollNo: rollCtrl.text.trim(),
            classNumber: student.classNumber,
            photoUrl: student.photoUrl,
            isStruckOff: student.isStruckOff,
            canStudentLogin: student.canStudentLogin,
            canParentView: student.canParentView,
            email: student.email,
            password: passCtrl.text.trim().isEmpty
                ? student.password
                : passCtrl.text.trim(),
            isPasswordCreated: student.isPasswordCreated,
            createdAt: student.createdAt,
            parentEmail: parentEmailCtrl.text.trim(),
            parentCnic: cnicCtrl.text.trim(),
            contactNumber: contactCtrl.text.trim(),
            address: addressCtrl.text.trim(),
            admissionDate: student.admissionDate,
            lifecycleStatus: student.lifecycleStatus,
            inactiveAt: student.inactiveAt,
            archivedAt: student.archivedAt,
            deleteEligibleAt: student.deleteEligibleAt,
            deletedAt: student.deletedAt,
          );

          // Save to firestore
          await dataService.addStudent(student.schoolId, updatedStudent);

          Get.back(); // close dialog
          Get.snackbar('Success', 'Profile updated effectively');
          // Reload the page immediately with updated data
          Get.off(
            () => const StudentDetailView(),
            arguments: updatedStudent,
            preventDuplicates: false,
          );
        } catch (e) {
          Get.defaultDialog(title: 'Error', middleText: e.toString());
        }
      },
    );
  }
}
