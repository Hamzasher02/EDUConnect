import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_text_field.dart';

class RegisterStudentView extends GetView<SchoolAdminController> {
  const RegisterStudentView({super.key});

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
        title: const Text(
          'New Registration',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: Form(
            key: controller.studentFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: AppColors.accentLime,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Enrolling for ${controller.selectedClass.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSection('Student Details'),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                GlassTextField(
                  label: 'Student Full Name *',
                  prefixIcon: Icons.person_outline,
                  controller: controller.regStudentNameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Student Email (Login ID) *',
                  hintText: 'e.g. shan@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  controller: controller.regStudentEmailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!GetUtils.isEmail(v)) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Roll Number *',
                  prefixIcon: Icons.tag,
                  controller: controller.regRollNoController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Roll number is required' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Password *',
                  prefixIcon: Icons.lock_outline,
                  controller: controller.regPasswordController,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters required';
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                _buildSection('Parent / Guardian Details'),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Guardian Email *',
                  prefixIcon: Icons.email_outlined,
                  controller: controller.regParentEmailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Guardian email is required';
                    if (!GetUtils.isEmail(v)) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Parent CNIC *',
                  hintText: 'e.g. 3520101234567',
                  prefixIcon: Icons.badge_outlined,
                  controller: controller.regParentCnicController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'CNIC is required' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Contact Number *',
                  prefixIcon: Icons.phone_outlined,
                  controller: controller.regContactNumberController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Contact number is required';
                    if (!GetUtils.isPhoneNumber(v)) return 'Invalid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Home Address *',
                  prefixIcon: Icons.home_outlined,
                  controller: controller.regHomeAddressController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Home address is required' : null,
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => controller.registerStudent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentLime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Register Student',
                      style: TextStyle(
                        color: AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.accentLime,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
