import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'firestore_helper.dart';
import '../data/models/parent_model.dart';
import '../data/models/student_model.dart';
import '../data/enums/app_enums.dart';

/// Parent Authentication Service integrated with Firebase
class ParentAuthService extends GetxService {
  static ParentAuthService get to => Get.find<ParentAuthService>();

  final _authService = Get.find<AuthService>();

  /// Login with Parent email and password via Firebase Auth
  Future<void> login(String loginId, String password) async {
    String email = loginId;

    // If it's a CNIC, resolve email first
    if (!loginId.contains('@')) {
      final parent = await getParentByCnic(loginId);
      if (parent == null) throw 'No parent record found for this CNIC';
      email = parent.email;
    }

    await _authService.login(email, password);

    // Validate role
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.parent) {
      await _authService.logout();
      throw 'Access denied: You are not registered as a parent.';
    }
  }

  /// Get all students linked to this parent from Firestore
  Future<List<StudentModel>> getLinkedStudents(String parentId) async {
    try {
      final parentDoc = await FirestoreHelper.parents.doc(parentId).get();
      if (!parentDoc.exists) return [];

      final data = parentDoc.data() as Map<String, dynamic>;
      final List<String> linkedIds = List<String>.from(
        data['linkedStudentIds'] ?? [],
      );

      if (linkedIds.isEmpty) return [];

      final studentQuery = await FirestoreHelper.students
          .where(FieldPath.documentId, whereIn: linkedIds)
          .get();

      return studentQuery.docs.map((doc) {
        return StudentModel.fromJson(
          doc.data() as Map<String, dynamic>..['id'] = doc.id,
        );
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch linked students: $e');
      return [];
    }
  }

  /// Validate CNIC format
  bool validateParentCnic(String cnic) {
    final cnicWithoutDashes = cnic.replaceAll('-', '');
    return cnicWithoutDashes.length == 13 &&
        int.tryParse(cnicWithoutDashes) != null;
  }

  /// Create or link parent during student registration (Firestore)
  Future<ParentModel?> createOrLinkParent({
    required String parentCnic,
    required String parentEmail,
    required String studentId,
    String? parentName,
    String? contactNumber,
  }) async {
    try {
      final query = await FirestoreHelper.parents
          .where('parentCnic', isEqualTo: parentCnic)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final existingParent = ParentModel.fromJson(
          doc.data() as Map<String, dynamic>..['id'] = doc.id,
        );

        if (!existingParent.linkedStudentIds.contains(studentId)) {
          final updatedIds = [...existingParent.linkedStudentIds, studentId];
          await doc.reference.update({
            'linkedStudentIds': updatedIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return existingParent.copyWith(linkedStudentIds: updatedIds);
        }
        return existingParent;
      }

      // Create new parent record in Firestore
      final newParentData = {
        'parentCnic': parentCnic,
        'name': parentName ?? '',
        'email': parentEmail,
        'contactNumber': contactNumber ?? '',
        'linkedStudentIds': [studentId],
        'isPasswordCreated': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirestoreHelper.parents.add(newParentData);

      return ParentModel.fromJson(newParentData..['id'] = docRef.id);
    } catch (e) {
      print('Error in createOrLinkParent: $e');
      return null;
    }
  }

  /// Get parent by ID from Firestore
  Future<ParentModel?> getParentById(String parentId) async {
    final doc = await FirestoreHelper.parents.doc(parentId).get();
    if (!doc.exists) return null;
    return ParentModel.fromJson(
      doc.data() as Map<String, dynamic>..['id'] = doc.id,
    );
  }

  /// Get parent by CNIC from Firestore
  Future<ParentModel?> getParentByCnic(String cnic) async {
    final query = await FirestoreHelper.parents
        .where('parentCnic', isEqualTo: cnic)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return ParentModel.fromJson(
      doc.data() as Map<String, dynamic>..['id'] = doc.id,
    );
  }
}
