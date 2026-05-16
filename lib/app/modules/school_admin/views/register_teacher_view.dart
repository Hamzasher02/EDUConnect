import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_text_field.dart';

class RegisterTeacherView extends GetView<SchoolAdminController> {
  const RegisterTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Faculty Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            key: controller.teacherFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const SizedBox(height: 32),

                _buildSection('Personal Details'),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Full Name *',
                  prefixIcon: Icons.person_outline,
                  controller: controller.regTeacherNameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Email Address *',
                  prefixIcon: Icons.alternate_email,
                  controller: controller.regTeacherEmailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!GetUtils.isEmail(v)) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Contact Number *',
                  prefixIcon: Icons.phone_android_outlined,
                  controller: controller.regTeacherContactController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Contact number is required';
                    if (!GetUtils.isPhoneNumber(v)) return 'Invalid phone number';
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                _buildSection('Professional Details'),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Qualification *',
                  prefixIcon: Icons.history_edu_outlined,
                  controller: controller.regTeacherQualificationController,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Qualification is required'
                      : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Experience (Years) *',
                  prefixIcon: Icons.work_outline,
                  keyboardType: TextInputType.number,
                  controller: controller.regTeacherExperienceController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Experience is required' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Subject Specialization *',
                  prefixIcon: Icons.auto_stories_outlined,
                  controller: controller.regTeacherSpecializationController,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Specialization is required'
                      : null,
                ),

                const SizedBox(height: 24),
                _buildSection('Security'),
                const SizedBox(height: 16),
                GlassTextField(
                  label: 'Password *',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: controller.regTeacherPasswordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters required';
                    return null;
                  },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.registerTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentLime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Register Faculty Member',
                      style: TextStyle(
                        color: AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
