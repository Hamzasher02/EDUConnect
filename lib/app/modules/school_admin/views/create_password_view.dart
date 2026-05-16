import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';

class CreatePasswordView extends GetView<SchoolAdminController> {
  const CreatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteId = Get.arguments?['inviteId'];
    // In a real app we would fetch the invitation via API.
    // Here we assume context is passed or we look it up from mock store
    final InvitationModel? invite = controller.invitations.firstWhereOrNull(
      (i) => i.token == inviteId,
    );

    if (invite == null || invite.isUsed) {
      return const Scaffold(
        body: Center(child: Text('Invalid or expired invitation link.')),
      );
    }

    if (controller.isOffline.value) {
      return const Scaffold(
        body: Center(child: Text('Offline: Cannot set password.')),
      );
    }

    final password = ''.obs;
    final confirmPassword = ''.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${invite.email}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please create a secure password for your account.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            Obx(
              () => TextField(
                onChanged: (v) => password.value = v,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                onChanged: (v) => confirmPassword.value = v,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (password.value != confirmPassword.value) {
                    Get.snackbar('Error', 'Passwords do not match');
                    return;
                  }
                  if (password.value.length < 8) {
                    Get.snackbar(
                      'Error',
                      'Password must be at least 8 characters',
                    );
                    return;
                  }

                  controller.markInviteUsed(inviteId, password.value);
                },
                child: const Text('Create Password & Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
