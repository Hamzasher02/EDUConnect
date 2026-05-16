import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../routes/app_routes.dart';

class AdminReportController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();

  final reportSearchQuery = ''.obs;
  final reportSelectedClass = 'All'.obs;
  final reportStatusFilter = ReportStatusFilter.all.obs;
  final reportResults = <StudentModel>[].obs;

  final studentReports = <String, StudentArchiveReportModel>{}.obs;
  final teacherReports = <String, TeacherArchiveReportModel>{}.obs;

  void generateReport() {
    Get.snackbar(
      'Success',
      'Report generated for ${reportSelectedClass.value}',
    );
    // Mock simulation
  }

  void downloadPdf() => Get.snackbar('Download', 'PDF Report Exported');
  void downloadExcel() => Get.snackbar('Download', 'Excel Report Exported');

  void goToArchivedStudents() => Get.toNamed(AppRoutes.adminArchivedStudents);
  void goToArchivedTeachers() => Get.toNamed(AppRoutes.adminArchivedTeachers);

  void openArchiveReportDetail({required bool isStudent, required String id}) {
    Get.toNamed(
      AppRoutes.adminArchiveReportDetail,
      arguments: {'type': isStudent ? 'student' : 'teacher', 'id': id},
    );
  }
}
