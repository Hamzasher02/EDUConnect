import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../modules/school_admin/models/school_admin_models.dart';

class StudentTimetableService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
  }

  Future<List<ClassTimetableSlotModel>> getWeeklyTimetable(
    String schoolId,
    String classNumber,
  ) async {
    _validateSession();

    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();
    final targetClass = normalize(classNumber);

    final allSlots = _schoolDataService.getTimetable(schoolId);
    return allSlots
        .where((slot) => normalize(slot.classNumber) == targetClass)
        .toList();
  }

  Future<List<ClassTimetableSlotModel>> getClassesForDay(
    String schoolId,
    String classNumber,
    String day,
  ) async {
    final weekly = await getWeeklyTimetable(schoolId, classNumber);
    final daySlots = weekly
        .where((slot) => slot.day.toLowerCase() == day.toLowerCase())
        .toList();

    // Sort chronologically by startTime (HH:mm format assumed)
    daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    return daySlots;
  }
}
