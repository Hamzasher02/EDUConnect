import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/glass_text_field.dart';
import '../controllers/school_controller.dart';

class RegisterSchoolView extends GetView<SchoolController> {
  const RegisterSchoolView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Register New School',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.purple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'School Information',
                      style: TextStyle(
                        color: AppColors.accentLime,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    GlassTextField(
                      controller: controller.nameController,
                      hintText: 'School Name *',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'School Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    GlassTextField(
                      controller: controller.addressController,
                      hintText: 'Address *',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.contactController,
                      hintText: 'Contact Number * (e.g., 03XXXXXXXXX)',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Contact number is required';
                        if (!GetUtils.isPhoneNumber(v)) return 'Invalid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.headNameController,
                      hintText: 'Principal / Head Name *',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Principal name is required'
                          : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Admin Information',
                      style: TextStyle(
                        color: AppColors.accentLime,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    GlassTextField(
                      controller: controller.adminEmailController,
                      hintText: 'School Admin Email *',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!GetUtils.isEmail(v)) return 'Invalid email format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.passwordController,
                      hintText: 'School Admin Password *',
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters required';
                        return null;
                      },
                    ),

                  const SizedBox(height: 32),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: controller.isRegistering.value
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentLime,
                              ),
                            )
                          : GlassButton(
                              text: 'Register School',
                              onPressed: controller.registerSchool,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
