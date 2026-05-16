import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/teacher_dashboard_controller.dart';
import '../controllers/teacher_timetable_controller.dart';
import '../controllers/teacher_attendance_controller.dart';
import '../controllers/teacher_result_controller.dart';
import '../controllers/teacher_assignment_controller.dart';
import '../controllers/teacher_student_controller.dart';
import '../controllers/teacher_exam_controller.dart';
import '../controllers/attendance_grid_controller.dart';
import '../controllers/result_matrix_controller.dart';
import '../services/teacher_dashboard_service.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherController>(() => TeacherController());
    Get.lazyPut<TeacherDashboardController>(() => TeacherDashboardController());
    Get.lazyPut<TeacherTimetableController>(() => TeacherTimetableController());
    Get.lazyPut<TeacherAttendanceController>(
      () => TeacherAttendanceController(),
    );
    Get.lazyPut<AttendanceGridController>(() => AttendanceGridController());
    Get.lazyPut<TeacherResultController>(() => TeacherResultController());
    Get.lazyPut<ResultMatrixController>(() => ResultMatrixController());
    Get.lazyPut<TeacherAssignmentController>(
      () => TeacherAssignmentController(),
    );
    Get.lazyPut<TeacherStudentController>(() => TeacherStudentController());
    Get.lazyPut<TeacherExamController>(() => TeacherExamController());
    Get.lazyPut<TeacherDashboardService>(() => TeacherDashboardService());
  }
}
