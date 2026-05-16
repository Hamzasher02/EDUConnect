import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/auth_service.dart';
import '../../../services/parent_auth_service.dart';
import '../../../services/parent_dashboard_service.dart';

/// Parent Controller - Manages parent state and navigation
class ParentController extends GetxController {
  final ParentAuthService _authService = Get.find();
  final ParentDashboardService _dashboardService = Get.find();

  // Reactive state
  final Rx<ParentModel?> currentParent = Rx<ParentModel?>(null);
  final RxList<StudentModel> linkedStudents = <StudentModel>[].obs;
  final Rx<StudentModel?> selectedStudent = Rx<StudentModel?>(null);
  final RxBool isLoading = false.obs;

  final RxBool isLoadingStudents = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize parent accurately
    _initFlow();
  }

  Future<void> _initFlow() async {
    final authService = Get.find<AuthService>();
    final session = authService.session.value;
    if (session != null && session.role == UserRole.parent) {
      await _initializeParentFromSession(session.userId);
    }

    // Initialize from arguments if parent was passed directly
    if (Get.arguments != null && Get.arguments is ParentModel) {
      currentParent.value = Get.arguments as ParentModel;
    }

    // Handle multi-student selection logic
    if (currentParent.value != null) {
      await _handleMultiStudentFlow();
    }
  }

  /// Initialize parent from session userId
  Future<void> _initializeParentFromSession(String parentId) async {
    try {
      final parent = await _authService.getParentById(parentId);
      if (parent != null) {
        currentParent.value = parent;
      }
    } catch (e) {
      // Silent fail - parent will be null
    }
  }

  /// Handles multi-student selection flow when parent logs in
  Future<void> _handleMultiStudentFlow() async {
    try {
      final parent = currentParent.value;
      if (parent == null) return;

      isLoadingStudents.value = true;

      // Load linked students
      await loadLinkedStudents();

      // Handle routing based on number of students
      if (linkedStudents.length > 1) {
        // Multiple students - navigate to selection screen
        Get.offAllNamed(AppRoutes.parentSelectStudent);
      } else if (linkedStudents.length == 1) {
        // Single student - auto-select
        selectStudent(linkedStudents.first);
        // Stay on dashboard (already here from router)
      } else {
        // No students - stay on dashboard, will show empty state
      }
    } catch (e) {
      // Stay on dashboard on error
      Get.snackbar(
        'Error',
        'Failed to load student information',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<void> loadLinkedStudents() async {
    if (currentParent.value == null) return;

    isLoading.value = true;
    try {
      final students = await _authService.getLinkedStudents(
        currentParent.value!.id,
      );
      linkedStudents.value = students;

      // If only one student, auto-select
      if (students.length == 1) {
        selectStudent(students.first);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a student for viewing and navigate to Student Dashboard
  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
    _dashboardService.selectStudent(student);

    // Unification Refactor: Navigate to Student Dashboard in "Parent Mode"
    Get.toNamed(
      AppRoutes.studentDashboard,
      arguments: {'studentId': student.id, 'viewAsParent': true},
    );
  }

  /// Switch to a different student (typically called from within dashboard if implemented)
  void switchStudent(StudentModel newStudent) {
    selectedStudent.value = newStudent;
    _dashboardService.switchStudent(newStudent);

    // If we support switching while already on dashboard, we might need a different approach,
    // but standard flow is select -> navigate.
    // If this is called, we should re-navigate or update controller.
    // For now, re-navigate to ensure clean state load.
    Get.offNamed(
      AppRoutes.studentDashboard,
      arguments: {'studentId': newStudent.id, 'viewAsParent': true},
      preventDuplicates: false,
    );
  }

  /// Update parent profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? contactNumber,
    String? address,
  }) async {
    if (currentParent.value == null) return false;

    try {
      final updatedParent = currentParent.value!.copyWith(
        name: name ?? currentParent.value!.name,
        email: email ?? currentParent.value!.email,
        contactNumber: contactNumber ?? currentParent.value!.contactNumber,
        address: address ?? currentParent.value!.address,
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await FirestoreHelper.parents.doc(currentParent.value!.id).update({
        'name': updatedParent.name,
        'email': updatedParent.email,
        'contactNumber': updatedParent.contactNumber,
        'address': updatedParent.address,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      currentParent.value = updatedParent;
      Get.snackbar('Success', 'Profile updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
      return false;
    }
  }

  /// Clear parent session (logout)
  void clearSession() {
    currentParent.value = null;
    linkedStudents.clear();
    selectedStudent.value = null;
    _dashboardService.clearSelection();
  }
}
