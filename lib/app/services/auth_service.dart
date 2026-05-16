import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_session.dart';
import '../data/enums/app_enums.dart';
import '../routes/role_router.dart';
import '../routes/app_routes.dart';
import 'firestore_helper.dart';
import 'school_data_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final _storage = GetStorage();
  final _sessionKey = 'user_session';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserSession?> session = Rx<UserSession?>(null);
  final RxString schoolStatus = 'active'.obs;
  bool get isLoggedIn => session.value != null;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();

    // Listen to session changes to start/stop school status listener
    ever(session, (session) {
      if (session != null && session.schoolId != null) {
        _listenToSchoolStatus(session.schoolId!);
      }
    });
  }

  void _listenToSchoolStatus(String schoolId) {
    FirestoreHelper.schools.doc(schoolId).snapshots().listen((doc) {
      if (!doc.exists) {
        // School was permanently deleted
        Get.snackbar(
          'Account Disabled',
          'Your school account has been removed from the platform.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        logout();
        return;
      }

      final status = (doc.data() as Map<String, dynamic>)['status'] ?? 'active';
      schoolStatus.value = status.toString().toLowerCase();

      if (schoolStatus.value == 'removed') {
        // School was soft removed
        Get.snackbar(
          'Account Disabled',
          'Your school account is currently suspended or removed.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        logout();
        return;
      }

      if (schoolStatus.value == 'restricted') {
        // If restricted and not on login/restricted, redirect to restricted view
        if (Get.currentRoute != AppRoutes.login &&
            Get.currentRoute != AppRoutes.restricted) {
          Get.offAllNamed(AppRoutes.restricted);
        }
      } else if (schoolStatus.value == 'active' ||
          schoolStatus.value == 'pending') {
        // If was restricted but now active/pending, and on restricted page, go back to dashboard
        if (Get.currentRoute == AppRoutes.restricted) {
          RoleRouter.routeToDashboard(session.value!.role);
        }
      }
    });
  }

  void _restoreSession() {
    final stored = _storage.read(_sessionKey);
    if (stored != null) {
      try {
        session.value = UserSession.fromJson(stored);
      } catch (e) {
        logout();
      }
    }
  }

  Future<void> login(String loginId, String password) async {
    try {
      if (loginId.contains('@')) {
        // Email-based login (Admin, School, Teacher, Student)
        await _handleEmailLogin(loginId, password);
      } else {
        // CNIC-based login (Parent)
        await _handleParentLogin(loginId, password);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Fallback for students and teachers who don't have a Firebase Auth account yet
        return await _handleCustomEmailLogin(loginId, password);
      }
      throw e.message ?? 'Authentication failed';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> _handleEmailLogin(String email, String password) async {
    // 1. Authenticate with Firebase Auth
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = userCredential.user;

    if (user == null) throw 'Login failed';

    // 2. Determine Role by querying centralized 'users' collection first (Sync requirement)
    final userDoc = await FirestoreHelper.db
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final role = UserRole.values[data['role']];
      print('DEBUG: [Auth] Registry entry found for uid ${user.uid}, role: $role');

      if (role == UserRole.student) {
        final schoolId = data['schoolId'];
        print('DEBUG: [Auth] Checking student access for school: $schoolId');
        if (schoolId != null) {
          final studentDoc = await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .collection('students')
              .doc(user.uid)
              .get();

          if (studentDoc.exists) {
            final studentData = studentDoc.data()!;
            if (!(studentData['canStudentLogin'] ?? true)) {
              await _auth.signOut();
              throw 'Access Denied: Your account has been disabled by the administrator.';
            }
          }
        }
      }

      _createSession(
        userId: user.uid,
        role: role,
        schoolId: data['schoolId'],
        email: email,
        name: data['name'] ?? 'User',
      );
      return;
    }

    // Fallback: Legacy lookup (for existing data before the sync was added)
    // Check School Admin
    final schoolQuery = await FirestoreHelper.schools
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (schoolQuery.docs.isNotEmpty) {
      final doc = schoolQuery.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      _createSession(
        userId: doc.id,
        role: UserRole.schoolAdmin,
        schoolId: doc.id,
        email: email,
        name: data['name'] ?? 'School Admin',
      );
      return;
    }

    // Check Teacher
    final teacherQuery = await FirestoreHelper.teachers
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (teacherQuery.docs.isNotEmpty) {
      final doc = teacherQuery.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      _createSession(
        userId: doc.id,
        role: UserRole.teacher,
        schoolId: data['schoolId'],
        email: email,
        name: data['name'] ?? 'Teacher',
      );
      return;
    }

    // Check Student
    final studentQuery = await FirestoreHelper.students
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (studentQuery.docs.isNotEmpty) {
      final doc = studentQuery.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      if (!(data['canStudentLogin'] ?? true)) {
        await _auth.signOut();
        throw 'Access Denied: Your account has been disabled by the administrator.';
      }

      _createSession(
        userId: doc.id,
        role: UserRole.student,
        schoolId: data['schoolId'],
        email: email,
        name: data['name'] ?? 'Student',
      );
      return;
    }

    // Check for Super Admin
    final superAdminQuery = await FirestoreHelper.db
        .collection('super_admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (superAdminQuery.docs.isNotEmpty) {
      final doc = superAdminQuery.docs.first;
      final data = doc.data();
      _createSession(
        userId: doc.id,
        role: UserRole.superAdmin,
        schoolId: null,
        email: email,
        name: data['name'] ?? 'Super Admin',
      );
      return;
    }

    // If not in DB, sign out
    await _auth.signOut();
    throw 'User record not found in database';
  }

  Future<void> _handleParentLogin(String cnic, String password) async {
    // Direct Firestore Query for Custom Auth (CNIC)
    final query = await FirestoreHelper.parents
        .where('cnic', isEqualTo: cnic)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      _createSession(
        userId: doc.id,
        role: UserRole.parent,
        email: data['email'],
        name: data['name'] ?? 'Parent',
        schoolId: null,
      );
    } else {
      throw 'Invalid CNIC or Password';
    }
  }

  Future<void> _handleCustomEmailLogin(String email, String password) async {
    print('DEBUG: [1] Starting _handleCustomEmailLogin for $email');
    try {
      final searchEmail = email.toLowerCase().trim();
      print(
        'DEBUG: [2] Querying Firestore users collection for $searchEmail...',
      );

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: searchEmail)
          .get();

      print('DEBUG: [3] Query complete. Found ${query.docs.length} entries.');

      if (query.docs.isNotEmpty) {
        // Filter by student or teacher roles
        final doc = query.docs.where((d) {
          final role = d.data()['role'];
          return role == UserRole.student.index ||
              role == UserRole.teacher.index;
        }).firstOrNull;

        if (doc != null) {
          final data = doc.data();
          final dbPassword = data['password'] as String?;
          print(
            'DEBUG: [4] Comparing passwords. DB password length: ${dbPassword?.length}',
          );

          if (dbPassword == password) {
            final role = UserRole.values[data['role']];
            if (role == UserRole.student) {
              final schoolId = data['schoolId'];
              if (schoolId != null) {
                final studentDoc = await FirebaseFirestore.instance
                    .collection('schools')
                    .doc(schoolId)
                    .collection('students')
                    .doc(doc.id)
                    .get();

                if (studentDoc.exists) {
                  final studentData = studentDoc.data()!;
                  if (!(studentData['canStudentLogin'] ?? true)) {
                    throw 'Access Denied: Your account has been disabled by the administrator.';
                  }
                }
              }
            }

            print(
              'DEBUG: [5] Password MATCH. Role: $role. Creating session for ${doc.id}',
            );
            _createSession(
              userId: doc.id,
              role: role,
              schoolId: data['schoolId'],
              email: email,
              name:
                  data['name'] ??
                  (role == UserRole.student ? 'Student' : 'Teacher'),
            );
            return;
          } else {
            print('DEBUG: [ERROR] Password mismatch.');
          }
        } else {
          print(
            'DEBUG: [ERROR] No student or teacher role doc found in registry results.',
          );
        }
      } else {
        print(
          'DEBUG: [6] No user found in registry for $searchEmail. trying per-school scan...',
        );

        final schoolDataService = Get.find<SchoolDataService>();
        final schoolIds = schoolDataService.schoolIds;
        print('DEBUG: [7] Scanning ${schoolIds.length} schools for record...');

        for (var schoolId in schoolIds) {
          // Check Students
          print('DEBUG: [7.1] Searching in school students: $schoolId');
          final studentQuery = await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .collection('students')
              .where('email', isEqualTo: searchEmail)
              .get();

          if (studentQuery.docs.isNotEmpty) {
            final doc = studentQuery.docs.first;
            final data = doc.data();
            if (data['password'] == password) {
              if (!(data['canStudentLogin'] ?? true)) {
                throw 'Access Denied: Your account has been disabled by the administrator.';
              }

              print(
                'DEBUG: [8] FOUND student in school: $schoolId. Auto-migrating.',
              );
              await _migrateAndCreateSession(
                doc.id,
                searchEmail,
                password,
                UserRole.student,
                schoolId,
                data['name'],
              );
              return;
            }
          }

          // Check Teachers
          print('DEBUG: [7.2] Searching in school teachers: $schoolId');
          final teacherQuery = await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .collection('teachers')
              .where('email', isEqualTo: searchEmail)
              .get();

          if (teacherQuery.docs.isNotEmpty) {
            final doc = teacherQuery.docs.first;
            final data = doc.data();
            if (data['password'] == password) {
              print(
                'DEBUG: [8.1] FOUND teacher in school: $schoolId. Auto-migrating.',
              );
              await _migrateAndCreateSession(
                doc.id,
                searchEmail,
                password,
                UserRole.teacher,
                schoolId,
                data['name'],
              );
              return;
            }
          }
        }
        print('DEBUG: [9] User not found in any school collection.');
      }
    } catch (e, stack) {
      print('DEBUG: [CRITICAL ERROR] during custom login: $e');
      print(stack);
      rethrow;
    }
    throw 'Invalid Email or Password';
  }

  Future<void> _migrateAndCreateSession(
    String uid,
    String email,
    String password,
    UserRole role,
    String schoolId,
    String? name,
  ) async {
    // 1. Migrate to registry
    await syncUserRegistry(
      uid: uid,
      email: email,
      role: role,
      schoolId: schoolId,
      name: name,
    );
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'password': password,
    });

    // 2. Create session
    _createSession(
      userId: uid,
      role: role,
      schoolId: schoolId,
      email: email,
      name: name ?? role.name.capitalizeFirst,
    );
  }

  void createSession({
    required String userId,
    required UserRole role,
    String? schoolId,
    String? email,
    String? name,
  }) {
    _createSession(
      userId: userId,
      role: role,
      schoolId: schoolId,
      email: email,
      name: name,
    );
  }

  void _createSession({
    required String userId,
    required UserRole role,
    String? schoolId,
    String? email,
    String? name,
  }) {
    final newSession = UserSession(
      userId: userId,
      role: role,
      schoolId: schoolId,
      email: email,
      name: name,
    );

    session.value = newSession;
    _storage.write(_sessionKey, newSession.toJson());

    RoleRouter.routeToDashboard(role);
  }

  Future<void> syncUserRegistry({
    required String uid,
    required String email,
    required UserRole role,
    String? schoolId,
    String? name,
    String? password,
  }) async {
    await FirestoreHelper.db.collection('users').doc(uid).set({
      'email': email,
      'role': role.index,
      'schoolId': schoolId,
      'name': name,
      if (password != null) 'password': password,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (name != null) await user.updateDisplayName(name);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    if (session.value != null) {
      final updated = UserSession(
        userId: session.value!.userId,
        role: session.value!.role,
        schoolId: session.value!.schoolId,
        email: session.value!.email,
        name: name ?? session.value!.name,
      );
      session.value = updated;
      _storage.write(_sessionKey, updated.toJson());

      // Sync to Firestore based on role
      final collection = _getCollectionForRole(session.value!.role);
      if (collection != null) {
        await collection.doc(session.value!.userId).update({
          if (name != null) 'name': name,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Also sync to global users registry
      await syncUserRegistry(
        uid: user.uid,
        email: user.email!,
        role: session.value!.role,
        schoolId: session.value!.schoolId,
        name: name,
      );
    }
  }

  CollectionReference? _getCollectionForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return FirestoreHelper.db.collection('super_admins');
      case UserRole.schoolAdmin:
        return FirestoreHelper.schools;
      case UserRole.teacher:
        return FirestoreHelper.teachers;
      case UserRole.student:
        return FirestoreHelper.students;
      case UserRole.parent:
        return FirestoreHelper.parents;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final query = await FirestoreHelper.db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> logout() async {
    await _auth.signOut();
    session.value = null;
    _storage.remove(_sessionKey);
    Get.offAllNamed(AppRoutes.publicRanking);
  }
}
