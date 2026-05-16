import 'package:get/get.dart';
import '../data/models/teacher_model.dart';
import '../data/enums/app_enums.dart';
import 'school_data_service.dart';

class TeacherService extends GetxService {
  static TeacherService get to => Get.find<TeacherService>();

  final SchoolDataService _schoolData = Get.find<SchoolDataService>();

  Future<TeacherModel> createTeacher({
    required TeacherModel teacher,
    required String schoolId,
    required UserRole currentUserRole,
  }) async {
    if (currentUserRole != UserRole.schoolAdmin) {
      throw 'Unauthorized: Only School Admins can register teachers.';
    }

    if (!GetUtils.isEmail(teacher.email)) throw 'Invalid email format.';

    _schoolData.addTeacher(schoolId, teacher);
    return teacher;
  }

  List<TeacherModel> getTeachersBySchool(String schoolId) {
    return _schoolData.getTeachers(schoolId);
  }

  Future<TeacherModel?> findTeacherByEmail(String email) async {
    return await _schoolData.findTeacherByEmailGlobal(email);
  }

  void updateTeacher(String schoolId, TeacherModel teacher) {
    _schoolData.updateTeacher(schoolId, teacher);
  }

  Future<void> deleteTeacher(String schoolId, String teacherId) async {
    await _schoolData.deleteTeacher(schoolId, teacherId);
  }
}
