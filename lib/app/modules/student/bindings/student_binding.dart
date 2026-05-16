import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../services/student_dashboard_service.dart';
import '../controllers/student_attendance_controller.dart';
import '../controllers/student_fee_controller.dart';
import '../controllers/student_timetable_controller.dart';
import '../controllers/student_assignment_controller.dart';
import '../controllers/student_result_controller.dart';
import '../controllers/student_messaging_controller.dart';
import '../controllers/student_profile_controller.dart';
import '../controllers/student_announcements_controller.dart';
import '../controllers/student_exam_controller.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_fee_service.dart';
import '../../../services/student_timetable_service.dart';
import '../../../services/student_assignment_service.dart';
import '../../../services/student_result_service.dart';
import '../../../services/student_messaging_service.dart';
import '../../../services/student_profile_service.dart';
import '../../../services/student_announcement_service.dart';
import '../../../services/student_exam_service.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentDashboardService>(() => StudentDashboardService());
    Get.lazyPut<StudentAttendanceService>(() => StudentAttendanceService());
    Get.lazyPut<StudentController>(() => StudentController());
    Get.lazyPut<StudentAttendanceController>(
      () => StudentAttendanceController(),
    );
    Get.lazyPut<StudentFeeService>(() => StudentFeeService());
    Get.lazyPut<StudentFeeController>(() => StudentFeeController());
    Get.lazyPut<StudentTimetableService>(() => StudentTimetableService());
    Get.lazyPut<StudentTimetableController>(() => StudentTimetableController());
    Get.lazyPut<StudentAssignmentService>(() => StudentAssignmentService());
    Get.lazyPut<StudentAssignmentController>(
      () => StudentAssignmentController(),
    );
    Get.lazyPut<StudentResultService>(() => StudentResultService());
    Get.lazyPut<StudentResultController>(() => StudentResultController());
    Get.lazyPut<StudentMessagingService>(() => StudentMessagingService());
    Get.lazyPut<StudentMessagingController>(() => StudentMessagingController());
    Get.lazyPut<StudentProfileService>(() => StudentProfileService());
    Get.lazyPut<StudentProfileController>(() => StudentProfileController());
    Get.lazyPut<StudentAnnouncementService>(() => StudentAnnouncementService());
    Get.lazyPut<StudentAnnouncementsController>(
      () => StudentAnnouncementsController(),
    );
    Get.lazyPut<StudentExamService>(() => StudentExamService());
    Get.lazyPut<StudentExamController>(() => StudentExamController());
  }
}
