import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/teacher_service.dart';

class AdminTeacherController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();
  final TeacherService _teacherService = Get.find<TeacherService>();

  final teacherEmail = ''.obs;
  final selectedTeacherId = ''.obs;

  List<TeacherModel> get teachers =>
      _teacherService.getTeachersBySchool(base.currentSchoolId);

  void registerTeacher() async {
    if (base.isOffline.value) {
      Get.snackbar('Offline', 'Cannot register teachers offline');
      return;
    }
    // Registration logic...
  }

  void removeTeacher(String teacherId) async {
    try {
      await Get.showOverlay(
        asyncFunction: () async {
          await _teacherService.deleteTeacher(base.currentSchoolId, teacherId);
        },
      );
      Get.snackbar('Success', 'Teacher removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove teacher: $e');
    }
  }

  List<TeacherModel> get archivedTeachers => teachers
      .where((t) => t.lifecycleStatus == TeacherLifecycleStatus.archived)
      .toList();
}
