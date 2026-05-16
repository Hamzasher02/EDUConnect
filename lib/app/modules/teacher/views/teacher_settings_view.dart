import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../models/teacher_models.dart';
import '../../../theme/app_colors.dart';

class TeacherSettingsView extends GetView<TeacherController> {
  const TeacherSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Obx(() {
        final currentSettings = controller.settings.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              _buildSettingCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dark Mode',
                      style: TextStyle(color: AppColors.white, fontSize: 16),
                    ),
                    Switch(
                      value: currentSettings.themeMode == 'dark',
                      activeThumbColor: AppColors.accentLime,
                      onChanged: (val) {
                        final updated = currentSettings.copyWith(
                          themeMode: val ? 'dark' : 'light',
                        );
                        controller.saveSettings(updated);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Notifications'),
              _buildSettingCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Notifications',
                      style: TextStyle(color: AppColors.white, fontSize: 16),
                    ),
                    Switch(
                      value: currentSettings.notificationsEnabled,
                      activeThumbColor: AppColors.accentLime,
                      onChanged: (val) {
                        final updated = currentSettings.copyWith(
                          notificationsEnabled: val,
                        );
                        controller.saveSettings(updated);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Data Refresh'),
              _buildSettingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto-refresh interval',
                      style: TextStyle(color: AppColors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Frequency: ${currentSettings.refreshInterval} minutes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<int>(
                      value: currentSettings.refreshInterval,
                      dropdownColor: AppColors.cardDark,
                      isExpanded: true,
                      underline: Container(),
                      style: const TextStyle(color: AppColors.white),
                      items: [5, 10, 15, 30, 60]
                          .map(
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text('$i Minutes'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final updated = currentSettings.copyWith(
                            refreshInterval: val,
                          );
                          controller.saveSettings(updated);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final defaults = TeacherSettingsModel(
                      themeMode: 'light',
                      notificationsEnabled: true,
                      refreshInterval: 15,
                    );
                    controller.saveSettings(defaults);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset Defaults'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentLime,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
