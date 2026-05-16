import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../data/models/academic_attendance_model.dart';
import '../services/teacher_dashboard_service.dart';

class AttendanceGridController extends GetxController {
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();
  final _dashboardService = Get.find<TeacherDashboardService>();

  final selectedClass = ''.obs;
  final selectedSubject = ''.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final gridData = Rxn<AttendanceGridModel>();
  final isLoading = false.obs;

  final assignedClasses = <String>[].obs;
  final assignedSubjects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssignedData();

    // Rebuild grid when data, selection, or month change
    everAll([
      _schoolDataService.students,
      _schoolDataService.subjectAttendance,
      selectedClass,
      selectedSubject,
      selectedMonth,
      selectedYear,
    ], (_) => _buildGrid());

    // Sync subjects when class changes
    ever(selectedClass, (String classNum) {
      if (classNum.isNotEmpty) {
        _updateSubjectsForClass(classNum);
      } else {
        assignedSubjects.clear();
      }
    });

    // Check for incoming arguments (from dashboard quick click)
    final args = Get.arguments;
    if (args != null) {
      if (args['classId'] != null) selectedClass.value = args['classId'];
      if (args['subjectId'] != null) selectedSubject.value = args['subjectId'];
    }
  }

  void _loadAssignedData() {
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    final Set<String> classes = timetable.map((s) => s.classNumber).toSet();
    classes.addAll(assigned.map((a) => a.classNumber));

    final classList = classes.toList();
    classList.sort();
    assignedClasses.assignAll(classList);

    if (classList.length == 1 && selectedClass.isEmpty) {
      selectedClass.value = classList.first;
    }
  }

  void _updateSubjectsForClass(String classNumber) {
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    final Set<String> subjects = timetable
        .where((s) => s.classNumber == classNumber)
        .map((s) => s.subjectName)
        .toSet();

    subjects.addAll(
      assigned
          .where((a) => a.classNumber == classNumber)
          .map((a) => a.subjectName),
    );

    final subjectList = subjects.toList();
    subjectList.sort();
    assignedSubjects.assignAll(subjectList);

    if (subjectList.length == 1) {
      selectedSubject.value = subjectList.first;
    }
  }

  List<String> getSubjectsForClass(String classNumber) {
    final timetable = _dashboardService.teacherTimetable;
    final assigned = _dashboardService.getAssignedClasses();

    final Set<String> subjects = timetable
        .where((s) => s.classNumber == classNumber)
        .map((s) => s.subjectName)
        .toSet();

    subjects.addAll(
      assigned
          .where((a) => a.classNumber == classNumber)
          .map((a) => a.subjectName),
    );

    final list = subjects.toList();
    list.sort();
    return list;
  }

  void _buildGrid() {
    final schoolId = _authService.session.value?.schoolId;
    final teacherId = _authService.session.value?.userId;

    if (schoolId == null ||
        teacherId == null ||
        selectedClass.isEmpty ||
        selectedSubject.isEmpty) {
      gridData.value = null;
      return;
    }

    // 1. Generate Dates for selected month
    final firstDay = DateTime(selectedYear.value, selectedMonth.value, 1);
    final lastDay = DateTime(selectedYear.value, selectedMonth.value + 1, 0);
    final List<DateTime> dates = [];
    for (int i = 0; i < lastDay.day; i++) {
      dates.add(firstDay.add(Duration(days: i)));
    }

    // 2. Fetch Students
    final classStudents = _schoolDataService.getStudentsByClass(
      schoolId,
      selectedClass.value,
    );

    // 3. Fetch Records
    final allRecords =
        _schoolDataService.subjectAttendance[schoolId] ??
        <SubjectAttendanceRecord>[];

    // Filter records for this triad and month
    final monthRecords = allRecords.where(
      (r) =>
          r.classId == selectedClass.value &&
          r.subjectId == selectedSubject.value &&
          r.date.month == selectedMonth.value &&
          r.date.year == selectedYear.value,
    );

    // 4. Build Rows
    final List<StudentAttendanceRow> rows = classStudents.map((student) {
      final Map<int, SubjectAttendanceRecord> dailyMap = {};

      for (var date in dates) {
        final existing = monthRecords.firstWhereOrNull(
          (r) =>
              r.studentId == student.id &&
              r.date.day == date.day &&
              r.date.month == date.month &&
              r.date.year == date.year,
        );

        dailyMap[date.day] =
            existing ??
            SubjectAttendanceRecord(
              id: '',
              studentId: student.id,
              studentName: student.name,
              classId: selectedClass.value,
              subjectId: selectedSubject.value,
              teacherId: teacherId,
              date: date,
              status: SubjectAttendanceStatus
                  .absent, // Default to absent if not marked? Or present?
              updatedAt: DateTime.now(),
            );
      }

      return StudentAttendanceRow(
        studentId: student.id,
        studentName: student.name,
        dailyRecords: dailyMap,
      );
    }).toList();

    gridData.value = AttendanceGridModel(dates: dates, rows: rows);
  }

  Future<void> setAttendanceStatus(
    String studentId,
    int day,
    SubjectAttendanceStatus status,
  ) async {
    final schoolId = _authService.session.value?.schoolId;
    final teacherId = _authService.session.value?.userId;
    if (schoolId == null || teacherId == null) return;

    final row = gridData.value?.rows.firstWhereOrNull(
      (r) => r.studentId == studentId,
    );
    final record = row?.dailyRecords[day];
    if (record == null) return;

    if (record.status == status) return;

    final log = AttendanceAuditLog(
      teacherId: teacherId,
      timestamp: DateTime.now(),
      previousStatus: record.status,
      newStatus: status,
    );

    final updated = record.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      history: [...record.history, log],
      teacherId: teacherId,
    );

    try {
      isLoading.value = true;
      await _schoolDataService.saveSubjectAttendance(schoolId, updated);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAttendance(String studentId, int day) async {
    // Legacy support or fallback
    final row = gridData.value?.rows.firstWhereOrNull(
      (r) => r.studentId == studentId,
    );
    final record = row?.dailyRecords[day];
    if (record == null) return;

    SubjectAttendanceStatus nextStatus;
    switch (record.status) {
      case SubjectAttendanceStatus.present:
        nextStatus = SubjectAttendanceStatus.absent;
        break;
      case SubjectAttendanceStatus.absent:
        nextStatus = SubjectAttendanceStatus.leave;
        break;
      case SubjectAttendanceStatus.leave:
        nextStatus = SubjectAttendanceStatus.present;
        break;
    }
    await setAttendanceStatus(studentId, day, nextStatus);
  }

  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
  }

  void prevMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
  }
}
