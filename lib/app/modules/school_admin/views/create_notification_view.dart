import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/glass_text_field.dart';

class CreateNotificationView extends GetView<SchoolAdminController> {
  const CreateNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notification Center',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Notification Category'),
              const SizedBox(height: 12),
              _buildTypeSelector(),

              const SizedBox(height: 24),
              _buildSection('Target Audience'),
              const SizedBox(height: 12),
              _buildAudienceDropdown(),

              const SizedBox(height: 12),
              Obx(() => _buildTargetInputs()),

              const SizedBox(height: 24),
              _buildSection('Message Content'),
              const SizedBox(height: 16),
              GlassTextField(
                label: 'Notification Title',
                prefixIcon: Icons.title_outlined,
                onChanged: (v) => controller.notifTitle.value = v,
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: TextField(
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => controller.notifMessage.value = v,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Send Multi-Channel Alert',
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

  Widget _buildTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NotificationType.values.map((type) {
          return Obx(() {
            final isSelected = controller.notifType.value == type;
            return GestureDetector(
              onTap: () => controller.notifType.value = type,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentLime.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.accentLime : Colors.white10,
                  ),
                ),
                child: Text(
                  type.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? AppColors.accentLime : Colors.white24,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildAudienceDropdown() {
    return GlassContainer(
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<NotificationAudience>(
            value: controller.notifAudience.value,
            dropdownColor: AppColors.cardDark,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            items: NotificationAudience.values.map((aud) {
              return DropdownMenuItem(
                value: aud,
                child: Text(
                  aud.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.notifAudience.value = val;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInputs() {
    final audience = controller.notifAudience.value;
    final showClass =
        (audience == NotificationAudience.classOnly ||
        audience == NotificationAudience.specificStudent);

    return Column(
      children: [
        if (showClass)
          GlassTextField(
            label: 'Target Class',
            prefixIcon: Icons.class_outlined,
            onChanged: (v) => controller.notifTargetClass.value = v,
          ),
        if (audience == NotificationAudience.specificStudent)
          const SizedBox(height: 12),
        if (audience == NotificationAudience.specificStudent)
          GlassTextField(
            label: 'Student Roll Number / ID',
            prefixIcon: Icons.person_search_outlined,
            onChanged: (v) => controller.notifTargetStudentId.value = v,
          ),
      ],
    );
  }
}
