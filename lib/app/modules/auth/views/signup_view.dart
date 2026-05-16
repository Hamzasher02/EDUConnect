import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/glass_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: 50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.accentLime.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Admin Account',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'One-time setup for Super Admin',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    GlassTextField(
                      controller: controller.adminIdController,
                      hintText: 'Super Admin ID',
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.passwordController,
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: controller.confirmPasswordController,
                      hintText: 'Confirm Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accentLime,
                                ),
                              )
                            : GlassButton(
                                text: 'Create Account',
                                onPressed: controller.signup,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: AppColors.accentLime),
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
