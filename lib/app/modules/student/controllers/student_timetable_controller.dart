import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/student_timetable_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../school_admin/models/school_admin_models.dart';

class StudentTimetableController extends GetxController {
  final _service = Get.find<StudentTimetableService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final dailyClasses = <ClassTimetableSlotModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  final selectedDay = ''.obs;
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String get _schoolId => _authService.session.value?.schoolId ?? '';

  String get _studentId => _authService.session.value?.userId ?? '';

  String get _classNumber {
    final student = _schoolDataService.students[_schoolId]?.firstWhereOrNull(
      (s) => s.id == _studentId,
    );
    return student?.classNumber ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);

    // Watch for student ID or school ID changes to reload classes
    ever(_authService.session, (_) => _autoSelectToday());

    // Watch students list in case class number is updated
    ever(_schoolDataService.students, (_) {
      if (_classNumber.isNotEmpty) loadDaySchedule(selectedDay.value);
    });

    _autoSelectToday();
  }

  void _autoSelectToday() {
    final now = DateTime.now();
    final dayName = DateFormat('EEE').format(now); // Mon, Tue, etc.
    if (weekDays.contains(dayName)) {
      selectedDay.value = dayName;
    } else {
      selectedDay.value = 'Mon'; // Default if Sunday
    }
    loadDaySchedule(selectedDay.value);
  }

  Future<void> loadDaySchedule(String day) async {
    try {
      isLoading.value = true;
      selectedDay.value = day;
      final data = await _service.getClassesForDay(
        _schoolId,
        _classNumber,
        day,
      );
      dailyClasses.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTimetable() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot refresh while offline');
      return;
    }
    await loadDaySchedule(selectedDay.value);
  }
}
