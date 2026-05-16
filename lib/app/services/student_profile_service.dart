import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../modules/student/models/profile_models.dart';
import '../data/enums/app_enums.dart';

class StudentProfileService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession(String studentId) {
    final session = _authService.session.value;
    if (session == null ||
        session.role != UserRole.student ||
        session.userId != studentId) {
      throw 'Unauthorized access to profile';
    }
  }

  Future<StudentProfileModel> fetchProfile(String studentId) async {
    _validateSession(studentId);

    final data = _schoolDataService.getStudentProfile(studentId);
    if (data == null) throw 'Profile not found';

    final profile = StudentProfileModel.fromJson(data);
    if (profile.status != 'Active') {
      throw 'Account is inactive. Please contact administration.';
    }

    return profile;
  }

  Future<void> updateProfile(
    String studentId, {
    String? phone,
    String? email,
    String? photoUrl,
  }) async {
    _validateSession(studentId);

    final data = _schoolDataService.getStudentProfile(studentId);
    if (data == null) throw 'Profile not found';

    final profile = StudentProfileModel.fromJson(data);

    // Validations
    if (email != null && !GetUtils.isEmail(email)) throw 'Invalid email format';
    if (phone != null && phone.length < 10) throw 'Invalid phone number';

    final updatedProfile = profile.copyWith(
      phone: phone,
      email: email,
      profilePictureUrl: photoUrl,
    );

    _schoolDataService.updateStudentProfile(studentId, updatedProfile.toJson());
  }
}
