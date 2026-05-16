import 'package:get/get.dart';
import '../data/enums/app_enums.dart';
import 'app_routes.dart';

class RoleRouter {
  static void routeToDashboard(UserRole role) {
    switch (role) {
      case UserRole.schoolAdmin:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case UserRole.teacher:
        Get.offAllNamed(AppRoutes.teacherDashboard);
        break;
      case UserRole.parent:
        Get.offAllNamed(AppRoutes.parentDashboard);
        break;
      case UserRole.student:
        Get.offAllNamed(AppRoutes.studentDashboard);
        break;
      case UserRole.superAdmin:
        // Super Admin uses a separate portal or the same admin dashboard for now
        Get.offAllNamed(AppRoutes.superAdminDashboard);
        break;
    }
  }
}
