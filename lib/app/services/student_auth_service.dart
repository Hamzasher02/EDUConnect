// Finalized Auth Service
import 'package:get/get.dart';
import 'school_data_service.dart';
import '../data/models/student_model.dart';
import '../data/enums/app_enums.dart';

class StudentAuthService extends GetxService {
  static StudentAuthService get to => Get.find<StudentAuthService>();

  final _schoolDataService = Get.find<SchoolDataService>();

  StudentModel? findStudentByEmail(String email) {
    // Search across all schools in mock DB
    for (var schoolId in _schoolDataService.schoolIds) {
      final students = _schoolDataService.getStudentsBySchool(schoolId);
      final student = students.firstWhereOrNull((s) => s.email == email);
      if (student != null) return student;
    }
    return null;
  }

  bool validateStudent(StudentModel student, String password) {
    // 1. Status Check
    if (student.lifecycleStatus != StudentLifecycleStatus.active) {
      throw 'Account is ${student.lifecycleStatus.name}. Please contact admin.';
    }

    // 2. Password Created Check
    if (!student.isPasswordCreated) {
      throw 'Password not created. Please check your email for the creation link.';
    }

    // 3. Password Match (Mock)
    if (password != '1234') {
      throw 'Invalid credentials';
    }

    return true;
  }
}
