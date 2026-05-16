import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../modules/student/models/exam_models.dart';
import '../data/enums/app_enums.dart';

class StudentExamService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
  }

  Future<List<StudentExamModel>> fetchExamSchedule(String studentId) async {
    _validateSession();
    final session = _authService.session.value!;
    final data = _schoolDataService.getStudentExams(
      studentId,
      session.schoolId,
    );
    final exams = data
        .map(
          (e) => StudentExamModel(
            examId: e.id,
            examName: e.examName,
            subject: e.subject,
            examDate: e.examDate,
            startTime: e.startTime,
            endTime: e.endTime,
            location: e.location,
            examType: e.type.name,
            teacherName: e.teacherName,
            instructions: e.instructions,
          ),
        )
        .toList();
    // Sort by date (earliest first)
    exams.sort((a, b) => a.examDate.compareTo(b.examDate));
    return exams;
  }

  Future<StudentExamModel?> getExamDetails(
    String studentId,
    String examId,
  ) async {
    _validateSession();
    final session = _authService.session.value!;
    final data = _schoolDataService.getStudentExams(
      studentId,
      session.schoolId,
    );
    final e = data.firstWhereOrNull((e) => e.id == examId);
    if (e == null) return null;
    return StudentExamModel(
      examId: e.id,
      examName: e.examName,
      subject: e.subject,
      examDate: e.examDate,
      startTime: e.startTime,
      endTime: e.endTime,
      location: e.location,
      examType: e.type.name,
      teacherName: e.teacherName,
      instructions: e.instructions,
    );
  }
}
