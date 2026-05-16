import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../theme/app_colors.dart';

class TeacherProfileView extends GetView<TeacherController> {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local controllers for form fields, initialized with current values
    final nameCtrl = TextEditingController(text: controller.name.value);
    final contactCtrl = TextEditingController(text: controller.contact.value);
    final addressCtrl = TextEditingController(text: controller.address.value);
    final qualCtrl = TextEditingController(
      text: controller.qualification.value,
    );
    final bloodCtrl = TextEditingController(text: controller.bloodGroup.value);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Offline Banner
            Obx(() {
              if (controller.isOffline.value) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(10),
                  color: Colors.redAccent,
                  width: double.infinity,
                  child: const Text(
                    'Offline Mode: You can edit but cannot save changes.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Profile Photo (Mock)
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.cardDark,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: AppColors.accentLime,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: AppColors.primaryBlack,
                        ),
                        onPressed: () {
                          if (!controller.isOffline.value) {
                            Get.snackbar(
                              'Mock Action',
                              'Photo upload dialog would open here',
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField('Full Name', nameCtrl, Icons.person),
            const SizedBox(height: 16),

            // Email Read-Only
            _buildReadOnlyField('Email', controller.email.value, Icons.email),
            const SizedBox(height: 16),

            _buildTextField(
              'Qualification',
              qualCtrl,
              Icons.school,
            ), // Editable if needed
            const SizedBox(height: 16),

            _buildTextField('Contact', contactCtrl, Icons.phone),
            const SizedBox(height: 16),

            _buildTextField('Address', addressCtrl, Icons.home),
            const SizedBox(height: 16),

            _buildTextField('Blood Group', bloodCtrl, Icons.bloodtype),
            const SizedBox(height: 24),

            // Subjects Taught (Read-Only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subjects Taught',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: controller.subjectsTaught
                          .map(
                            (sub) => Chip(
                              label: Text(
                                sub,
                                style: const TextStyle(
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              backgroundColor: AppColors.accentLime,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Formal Assignments (Read-Only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formal Assignments',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final assignments = controller.schoolDataService
                        .getTeacherAssignmentsBySchool(controller.currentSchoolId)
                        .where((a) => a.teacherId == controller.authService.session.value?.userId)
                        .toList();

                    if (assignments.isEmpty) {
                      return const Text(
                        'No formal assignments yet',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: assignments.map((a) {
                        return Chip(
                          label: Text(
                            'Class ${a.classNumber} - ${a.subjectName}',
                            style: const TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: AppColors.accentLime.withValues(alpha: 0.8),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isOffline.value
                      ? null
                      : () async {
                          // Validation
                          if (nameCtrl.text.isEmpty ||
                              contactCtrl.text.isEmpty ||
                              addressCtrl.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Name, Contact and Address are required',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // Mock Save Delay
                          await Future.delayed(const Duration(seconds: 1));

                          controller.updateProfile(
                            nameCtrl.text,
                            contactCtrl.text,
                            addressCtrl.text,
                            qualCtrl.text,
                            bloodCtrl.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppColors.accentLime),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      style: const TextStyle(color: Colors.white60),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: AppColors.cardDark.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
