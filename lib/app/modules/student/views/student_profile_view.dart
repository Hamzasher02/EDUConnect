import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_profile_controller.dart';
import '../../../widgets/glass_container.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentLime),
          );
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(
            child: Text(
              'Profile not found',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(profile),
              const SizedBox(height: 32),
              _buildInfoSection('Academic Details', [
                _buildInfoTile(
                  'Roll Number',
                  profile.rollNo,
                  Icons.badge_outlined,
                ),
                _buildInfoTile(
                  'Class',
                  profile.className,
                  Icons.class_outlined,
                ),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection('Contact Details', [
                _buildInfoTile(
                  'Email',
                  profile.email,
                  Icons.email_outlined,
                  canEdit: true,
                ),
                _buildInfoTile(
                  'Phone',
                  profile.phone.isEmpty ? 'Not set' : profile.phone,
                  Icons.phone_outlined,
                  canEdit: true,
                ),
              ]),
              const SizedBox(height: 32),
              if (controller.isOffline.value)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Offline Mode - Edits disabled',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(StudentProfileModel profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentLime, width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.cardDark,
                child: Text(
                  profile.name.isNotEmpty ? profile.name.substring(0, 1) : 'S',
                  style: const TextStyle(
                    color: AppColors.accentLime,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () =>
                    controller.isOffline.value ? null : _showEditModal(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.accentLime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Student ID: ${profile.id}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.all(8),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon, {
    bool canEdit = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.accentLime.withValues(alpha: 0.7),
        size: 20,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: canEdit && !controller.isOffline.value
          ? const Icon(Icons.chevron_right, color: Colors.white12)
          : null,
      onTap: canEdit && !controller.isOffline.value ? _showEditModal : null,
    );
  }

  void _showEditModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Email Address', controller.emailController),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', controller.phoneController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Obx(
                  () => controller.isUpdating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildTextField(String label, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
