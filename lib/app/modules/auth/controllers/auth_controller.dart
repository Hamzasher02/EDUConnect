import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/firestore_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../services/audit_service.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  // final _teacherService = Get.find<TeacherService>(); // Moved to AuthService
  final _authService = Get.find<AuthService>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final adminIdController = TextEditingController(); // For Signup

  // One-time signup flag
  final _isFirstTime = true.obs;
  bool get isFirstTime => _isFirstTime.value;

  // Loading state
  final isLoading = false.obs;

  // Mock stored credentials (Legacy/Fallback - consider removing if not needed)
  final _storedEmail = 'admin@gmail.com'.obs;
  final _storedPassword = '1234'.obs;
  final _storedAdminId = ''.obs;

  Future<void> signup() async {
    // Validate all fields are filled
    if (emailController.text.isEmpty ||
        adminIdController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    // Validate email format
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Invalid email format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    // Password match validation
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    // Password complexity validation (min 8 chars, 1 number)
    if (passwordController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    if (!passwordController.text.contains(RegExp(r'[0-9]'))) {
      Get.snackbar(
        'Error',
        'Password must contain at least 1 number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 0. Strict Single Super Admin Policy: Check if any Super Admin already exists
      final existingAdmins = await FirebaseFirestore.instance
          .collection('super_admins')
          .limit(1)
          .get();

      if (existingAdmins.docs.isNotEmpty) {
        Get.snackbar(
          'Access Denied',
          'A Super Admin account already exists in the system. Only one Super Admin is permitted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // 1. Create Auth User in Firebase
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Sync to Global User Registry (Firestore 'users' collection)
      await _authService.syncUserRegistry(
        uid: uid,
        email: emailController.text.trim(),
        role: UserRole.superAdmin,
        name: adminIdController.text.trim(),
      );

      // 3. Save to 'super_admins' collection (Legacy Fallback)
      await FirestoreHelper.db.collection('super_admins').doc(uid).set({
        'email': emailController.text.trim(),
        'name': adminIdController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update local credentials (for backward compatibility if needed)
      _storedEmail.value = emailController.text;
      _storedPassword.value = passwordController.text;
      _storedAdminId.value = adminIdController.text;
      _isFirstTime.value = false;

      // Audit Log
      if (Get.isRegistered<AuditService>()) {
        AuditService.to.logAction(
          actionType: 'SUPER_ADMIN_SIGNUP',
          targetType: 'AUTH',
          targetId: adminIdController.text,
          performedBy: emailController.text,
          metadata: {'email': emailController.text, 'uid': uid},
        );
      }

      Get.snackbar(
        'Success',
        'Super Admin Account Created and Registered in Firebase',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.5),
        colorText: Colors.white,
      );

      // Navigate to Login
      Get.offAllNamed(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.message ?? 'Firebase interaction failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    // Validate fields
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email and password are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
      return;
    }

    final loginId = emailController.text.trim();
    final password = passwordController.text;

    try {
      await _authService.login(loginId, password);
      // Audit Log for Admin (if successful and was admin) - Optional enhancement
      // But AuthService handles routing.
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    }
  }

  void logout() {
    _authService.logout();
    // Audit Log is less clean here since we don't know who was logged in easily without querying AuthSession
    // But AuthService handles generic logout.
  }

  void updateProfile(String newEmail) {
    _storedEmail.value = newEmail;
    // Audit Log
    if (Get.isRegistered<AuditService>()) {
      AuditService.to.logAction(
        actionType: 'PROFILE_UPDATE',
        targetType: 'AUTH',
        targetId: _storedEmail.value,
        performedBy: _storedEmail.value,
        metadata: {'newEmail': newEmail},
      );
    }
    Get.back();
    Get.snackbar(
      'Success',
      'Profile Updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void changePassword(String current, String newPass) {
    if (current != _storedPassword.value) {
      Get.snackbar(
        'Error',
        'Incorrect current password',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (newPass.length < 8) {
      Get.snackbar(
        'Error',
        'New password must be 8+ chars',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    _storedPassword.value = newPass;
    // Audit Log
    if (Get.isRegistered<AuditService>()) {
      AuditService.to.logAction(
        actionType: 'PASSWORD_CHANGE',
        targetType: 'AUTH',
        targetId: _storedEmail.value,
        performedBy: _storedEmail.value,
      );
    }
    Get.back();
    Get.snackbar(
      'Success',
      'Password Changed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
