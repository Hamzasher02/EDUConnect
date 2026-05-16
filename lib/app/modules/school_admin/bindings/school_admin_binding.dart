import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../controllers/base_admin_controller.dart';
import '../controllers/admin_student_controller.dart';
import '../controllers/admin_fee_controller.dart';
import '../controllers/admin_exam_controller.dart';
import '../controllers/admin_announcement_controller.dart';
import '../controllers/admin_report_controller.dart'; // Added this import
import '../controllers/admin_teacher_controller.dart';
import '../controllers/admin_timetable_controller.dart';

class SchoolAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseAdminController>(() => BaseAdminController());
    Get.lazyPut<AdminStudentController>(() => AdminStudentController());
    Get.lazyPut<AdminFeeController>(() => AdminFeeController());
    Get.lazyPut<AdminExamController>(() => AdminExamController());
    Get.lazyPut<AdminAnnouncementController>(
      () => AdminAnnouncementController(),
    );
    Get.lazyPut<AdminTeacherController>(() => AdminTeacherController());
    Get.lazyPut<AdminTimetableController>(() => AdminTimetableController());
    Get.lazyPut<AdminReportController>(
      () => AdminReportController(),
    ); // Added this dependency

    // Legacy support during transition
    Get.lazyPut<SchoolAdminController>(() => SchoolAdminController());
  }
}
