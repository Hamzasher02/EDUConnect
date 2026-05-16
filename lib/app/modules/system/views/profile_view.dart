import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/glass_text_field.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local controllers for edit fields
    final emailEditController = TextEditingController(
      text: controller.emailController.text,
    );
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Are you sure you want to logout?',
                textConfirm: 'Logout',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: controller.logout,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
color: Colors.blue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar Section
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accentLime,
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'System Administrator',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 32),

                // Edit Profile Section
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: AppColors.accentLime,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        controller: emailEditController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          text: 'Update Profile',
                          onPressed: () {
                            controller.updateProfile(emailEditController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Change Password Section
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        controller: currentPassController,
                        hintText: 'Current Password',
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        controller: newPassController,
                        hintText: 'New Password',
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          text: 'Change Password',
                          onPressed: () {
                            controller.changePassword(
                              currentPassController.text,
                              newPassController.text,
                            );
                          },
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


