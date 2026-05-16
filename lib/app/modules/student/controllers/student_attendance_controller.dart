import 'package:get/get.dart';
import '../../student/models/attendance_models.dart';
import '../../../data/models/attendance_record_model.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentAttendanceController extends GetxController {
  final _service = Get.find<StudentAttendanceService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();
  // final _storage = GetStorage();

  final summaries = <MonthlyAttendanceSummary>[].obs;
  final subjectSummaries = <SubjectAttendanceSummary>[].obs;
  final currentMonthDetails = <AttendanceRecordModel>[].obs;
  final allAttendance = <AttendanceRecordModel>[].obs;
  final selectedSummary = Rxn<MonthlyAttendanceSummary>();

  final totalPresent = 0.obs;
  final totalAbsent = 0.obs;
  final totalLeave = 0.obs;
  final overallPercentage = 0.0.obs;

  final isLoading = false.obs;
  final isOffline = false.obs;

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);
    loadOverallAttendance();
    loadMonthlyAttendance();
    loadSubjectSummaries();
  }

  Future<void> loadOverallAttendance() async {
    try {
      isLoading.value = true;
      final all = _schoolDataService.getStudentAttendance(_studentId);
      allAttendance.assignAll(all..sort((a, b) => b.date.compareTo(a.date)));

      int present = 0;
      int absent = 0;
      int leave = 0;

      for (var att in all) {
        if (att.status == AttendanceStatus.present) {
          present++;
        } else if (att.status == AttendanceStatus.absent) {
          absent++;
        } else if (att.status == AttendanceStatus.leave) {
          leave++;
        }
      }

      totalPresent.value = present;
      totalAbsent.value = absent;
      totalLeave.value = leave;

      if (present + absent > 0) {
        overallPercentage.value = (present / (present + absent)) * 100;
      } else {
        overallPercentage.value = 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load overall attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubjectSummaries() async {
    try {
      isLoading.value = true;
      final data = await _service.getSubjectWiseSummaries(_studentId);
      subjectSummaries.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subject summaries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthlyAttendance() async {
    try {
      isLoading.value = true;
      final data = await _service.getMonthlyAttendanceSummaries(_studentId);
      summaries.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthDetails(MonthlyAttendanceSummary summary) async {
    try {
      isLoading.value = true;
      selectedSummary.value = summary;
      final details = await _service.getAttendanceByMonth(
        _studentId,
        summary.month,
        summary.year,
      );
      currentMonthDetails.assignAll(details);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendance() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot refresh while offline');
      return;
    }
    await loadOverallAttendance();
    await loadMonthlyAttendance();
    await loadSubjectSummaries();
  }
}
