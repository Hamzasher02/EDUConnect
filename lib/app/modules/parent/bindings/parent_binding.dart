import 'package:get/get.dart';
import '../controllers/parent_controller.dart';
import '../../../services/parent_auth_service.dart';
import '../../../services/parent_dashboard_service.dart';

/// Parent Module Binding - Injects parent-specific controllers and services
class ParentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure parent services are available
    Get.lazyPut<ParentAuthService>(() => ParentAuthService());
    Get.lazyPut<ParentDashboardService>(() => ParentDashboardService());
    
    // Initialize parent controller
    Get.lazyPut<ParentController>(() => ParentController());
  }
}
