import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/models/school_model.dart';
import '../../../services/audit_service.dart';
import '../../../services/firestore_helper.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/enums/app_enums.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class SchoolController extends GetxController {
  // Registration Form Controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final adminEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final headNameController = TextEditingController();
  final RxBool isRegistering = false.obs;
  final formKey = GlobalKey<FormState>();

  final RxString selectedCategory = 'Improving'.obs; // Default category

  // For Detail View
  final Rx<SchoolModel?> selectedSchool = Rx<SchoolModel?>(null);

  Future<void> registerSchool() async {
    if (isRegistering.value) return;

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final contact = contactController.text.trim();
    final email = adminEmailController.text.trim();
    final password = passwordController.text.trim();
    final headName = headNameController.text.trim();

    // Validate all required fields
    if (name.isEmpty ||
        address.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        headName.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields (marked with *) are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Validate email format
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Invalid email format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Validate Contact Number (basic check for digits only and reasonable length)
    if (!GetUtils.isPhoneNumber(contact) || contact.length < 10) {
      Get.snackbar(
        'Error',
        'Invalid contact number format. Use at least 10 digits.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isRegistering.value = true;
      print('DEBUG: [1] Starting school registration process...');
      // 0. Check for duplicates (Same Name or Same Email)
      final nameCheck = await FirestoreHelper.schools
          .where('name', isEqualTo: name)
          .get();
      if (nameCheck.docs.isNotEmpty) {
        Get.snackbar(
          'Duplicate Error',
          'A school with this name already exists.',
          backgroundColor: Colors.orange,
        );
        return;
      }

      final emailCheck = await AuthService.to.checkEmailExists(email);
      if (emailCheck) {
        Get.snackbar(
          'Duplicate Error',
          'This email is already registered to another school or user.',
          backgroundColor: Colors.orange,
        );
        return;
      }

      print(
        'DEBUG: [2] Creating Firebase Auth user for admin (Security Check)...',
      );
      // 1. Create Auth User for School Admin WITHOUT signing out Super Admin
      // Use a secondary Firebase App instance
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SchoolAdminCreator');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SchoolAdminCreator',
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      print('DEBUG: [3] Auth user created. UID: $uid');

      // 2. Create School document in Firestore
      final schoolRef = FirestoreHelper.schools.doc();
      final schoolId = schoolRef.id;

      final newSchool = SchoolModel(
        id: schoolId,
        name: name,
        address: address,
        contactNumber: contact,
        adminEmail: email,
        adminUid: uid,
        adminPassword: password,
        principalName: headName,
        registrationDate: DateTime.now(),
        status: 'active', // Ensure it is active to show in rankings
        studentCount: 0,
        teacherCount: 0,
        adminCount: 1,
        category: 'Improving', // Default Category per FRS
        rankingScore: 0.0,
        logoUrl: null,
      );

      final schoolData = newSchool.toJson();
      schoolData['isVisibleOnRanking'] = true;

      await schoolRef.set(schoolData);

      // 3. Sync to Global User Registry
      await AuthService.to.syncUserRegistry(
        uid: uid,
        email: email,
        role: UserRole.schoolAdmin,
        schoolId: schoolId,
        name: headName,
      );

      // Audit Log
      AuditService.to.logAction(
        actionType: 'SCHOOL_REGISTERED',
        targetType: 'SCHOOL',
        targetId: schoolId,
        performedBy: 'Super Admin',
        metadata: {
          'schoolName': newSchool.name,
          'adminEmail': newSchool.adminEmail,
          'adminUid': uid,
        },
      );

      // Navigate to School Detail screen for immediate feedback
      Get.offNamed(AppRoutes.schoolDetail, arguments: newSchool);

      Get.snackbar(
        'Success',
        'School Registered Successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear controllers
      nameController.clear();
      addressController.clear();
      contactController.clear();
      adminEmailController.clear();
      passwordController.clear();
      headNameController.clear();
      selectedCategory.value = 'Improving';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isRegistering.value = false;
    }
  }

  void removeSchool() {
    Get.defaultDialog(
      title: 'Remove School',
      middleText: 'What would you like to do with this school?',
      textConfirm: 'Soft Remove',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (selectedSchool.value != null) {
          final schoolId = selectedSchool.value!.id;
          // Soft delete: set status to 'removed'
          selectedSchool.value!.status = 'removed';
          selectedSchool.refresh();

          // Update in Firestore
          FirestoreHelper.schools.doc(schoolId).update({
            'status': 'removed',
          });

          // Update in main list
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().schools.refresh();
          }

          // Audit Log
          AuditService.to.logAction(
            actionType: 'SCHOOL_REMOVED',
            targetType: 'SCHOOL',
            targetId: selectedSchool.value!.id,
            performedBy: 'Super Admin',
            metadata: {'schoolName': selectedSchool.value!.name},
          );

          Get.back(); // Close dialog
          Get.back(); // Go back to dashboard
          Get.snackbar(
            'Success',
            'School status set to REMOVED',
            colorText: Colors.white,
            backgroundColor: Colors.orange,
          );
        }
      },
      actions: [
        TextButton(
          onPressed: () => permanentlyDeleteSchool(),
          child: const Text(
            'Permanently Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void permanentlyDeleteSchool() async {
    if (selectedSchool.value == null) return;

    Get.defaultDialog(
      title: 'WARNING',
      middleText:
          'This will PERMANENTLY delete all data for ${selectedSchool.value!.name}, including all associated Admin, Teacher, and Student login credentials. This cannot be undone.',
      textConfirm: 'DELETE FOREVER',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          final schoolId = selectedSchool.value!.id;

          // 1. Delete all associated users from the registry (prevents login)
          final associatedUsers = await FirebaseFirestore.instance
              .collection('users')
              .where('schoolId', isEqualTo: schoolId)
              .get();

          for (var doc in associatedUsers.docs) {
            await doc.reference.delete();
          }

          // 2. Delete the School document
          await FirestoreHelper.schools.doc(schoolId).delete();

          // 3. Remove from local list
          if (Get.isRegistered<DashboardController>()) {
            final dash = Get.find<DashboardController>();
            dash.schools.removeWhere((s) => s.id == schoolId);
            dash.schools.refresh();
          }

          // 4. Audit Log
          AuditService.to.logAction(
            actionType: 'SCHOOL_PERMANENTLY_DELETED',
            targetType: 'SCHOOL',
            targetId: schoolId,
            performedBy: 'Super Admin',
            metadata: {
              'schoolName': selectedSchool.value!.name,
              'deletedUserCount': associatedUsers.docs.length,
            },
          );

          Get.close(2); // Close both confirmation dialogs
          Get.back(); // Go back to dashboard

          Get.snackbar(
            'Success',
            'School and all associated credentials deleted.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar('Error', 'Failed to delete school: $e');
        }
      },
    );
  }

  void updateStatus(String newStatus) async {
    if (selectedSchool.value != null) {
      final oldStatus = selectedSchool.value!.status;
      final canonicalStatus = newStatus.toLowerCase();

      // Update locally
      selectedSchool.value!.status = canonicalStatus;
      selectedSchool.refresh();

      // Update in Firestore
      try {
        await FirestoreHelper.schools.doc(selectedSchool.value!.id).update({
          'status': canonicalStatus,
        });

        // Audit Log
        AuditService.to.logAction(
          actionType: 'STATUS_CHANGED',
          targetType: 'SCHOOL',
          targetId: selectedSchool.value!.id,
          performedBy: 'Super Admin',
          metadata: {
            'schoolName': selectedSchool.value!.name,
            'oldStatus': oldStatus,
            'newStatus': newStatus,
          },
        );

        Get.snackbar(
          'Success',
          'Status updated to $newStatus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to update status: $e');
      }
    }
  }

  void toggleRankingVisibility() async {
    if (selectedSchool.value != null) {
      final newValue = !selectedSchool.value!.isVisibleOnRanking;

      // Update locally
      selectedSchool.value!.isVisibleOnRanking = newValue;
      selectedSchool.refresh();

      try {
        await FirestoreHelper.schools.doc(selectedSchool.value!.id).update({
          'isVisibleOnRanking': newValue,
        });

        // Also update rankings collection if it exists to sync public visibility
        final rankingDoc = await FirestoreHelper.rankings
            .doc(selectedSchool.value!.id)
            .get();
        if (rankingDoc.exists) {
          await FirestoreHelper.rankings.doc(selectedSchool.value!.id).update({
            'isVisible': newValue,
          });
        }

        AuditService.to.logAction(
          actionType: 'RANKING_VISIBILITY_TOGGLED',
          targetType: 'SCHOOL',
          targetId: selectedSchool.value!.id,
          performedBy: 'Super Admin',
          metadata: {
            'schoolName': selectedSchool.value!.name,
            'isVisible': newValue,
          },
        );

        Get.snackbar(
          'Success',
          newValue
              ? 'School is now visible on Ranking'
              : 'School is now hidden from Ranking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accentLime,
          colorText: Colors.black,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to update visibility: $e');
      }
    }
  }
}
