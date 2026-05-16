import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String rollNo;
  final String className;

  StudentProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rollNo,
    required this.className,
  });

  factory StudentProfileModel.fromStudent(StudentModel s) {
    return StudentProfileModel(
      id: s.id,
      name: s.name,
      email: s.email ?? '',
      phone: s.contactNumber ?? '',
      rollNo: s.rollNo,
      className: s.classNumber,
    );
  }
}

class StudentProfileController extends GetxController {
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final profile = Rxn<StudentProfileModel>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final isOffline = false.obs;

  // Edit Controllers
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final studentId = _studentId;
      if (studentId.isEmpty) return;

      // Use SchoolDataService to find student profile
      final schoolId = _authService.session.value?.schoolId ?? '';
      final students = _schoolDataService.getStudentsBySchool(schoolId);
      final student = students.firstWhereOrNull((s) => s.id == studentId);

      if (student != null) {
        profile.value = StudentProfileModel.fromStudent(student);
        phoneController.text = profile.value?.phone ?? '';
        emailController.text = profile.value?.email ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot update profile while offline');
      return;
    }

    try {
      isUpdating.value = true;
      final studentId = _studentId;
      if (studentId.isEmpty) return;

      // Mock update via SchoolDataService (would update actual model in real app)
      _schoolDataService.updateStudentProfile(studentId, {
        'contactNumber': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });

      await loadProfile(); // Refresh UI
      Get.back(); // Close modal
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
