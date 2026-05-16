import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../data/enums/app_enums.dart';
import '../models/student_models.dart';
import '../../../data/models/submission_model.dart' as global_submission;

class StudentDashboardService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  String get _currentUserId => _authService.session.value?.userId ?? '';
  String? get _schoolId => _authService.session.value?.schoolId;
  String? get schoolId => _schoolId;

  // Validate session - allow Student OR Parent (if studentId provided)
  void _validateSession({String? targetStudentId}) {
    final session = _authService.session.value;
    if (session == null) throw 'Unauthorized access';

    if (session.role == UserRole.student) {
      // Student must use their own ID
      return;
    }

    if (session.role == UserRole.parent && targetStudentId != null) {
      // Parent is allowed if they are viewing a specific student
      // Ideally we should verify the parent is linked to this student here too
      return;
    }

    throw 'Unauthorized access';
  }

  Future<StudentDashboardData> fetchStudentDashboardData({
    String? studentId,
  }) async {
    // If studentId is provided (e.g. by Parent), use it. Otherwise use current user ID.
    final targetId = studentId ?? _currentUserId;
    _validateSession(targetStudentId: studentId);

    final schoolId = _schoolId;
    if (schoolId == null) throw 'School ID missing in session';

    final student = _schoolDataService
        .getStudentsBySchool(schoolId)
        .firstWhereOrNull((s) => s.id == targetId);

    if (student == null) throw 'Student not found';
    if (student.lifecycleStatus != StudentLifecycleStatus.active) {
      throw 'Student account is not active';
    }

    // --- Real Calculations ---
    final attendanceRecords =
        _schoolDataService.subjectAttendance[schoolId]
            ?.where((r) => r.studentId == targetId)
            .toList() ??
        [];
    double attendancePercentage = 0.0;
    if (attendanceRecords.isNotEmpty) {
      final presentCount = attendanceRecords
          .where((r) => r.status.name == 'present')
          .length;
      attendancePercentage = presentCount / attendanceRecords.length;
    }

    final results = _schoolDataService.getStudentResults(targetId);
    double totalObtained = 0;
    double totalMax = 0;
    for (var res in results) {
      totalObtained += res.marksObtained;
      totalMax += res.totalMarks;
    }

    // Include Assignments
    final assignments =
        _schoolDataService.submissions[schoolId] ??
        <global_submission.SubmissionModel>[];
    final studentSubmissions = assignments.where(
      (s) =>
          s.studentId == targetId &&
          s.status == global_submission.SubmissionStatus.graded,
    );
    for (var subm in studentSubmissions) {
      totalObtained += subm.marksObtained ?? 0;
      totalMax += subm.maxMarks;
    }

    final overallPerformance = totalMax > 0
        ? '${((totalObtained / totalMax) * 100).toStringAsFixed(0)}%'
        : 'N/A';

    final todaysClasses = await getTodayClasses(studentId: targetId);
    final upcomingClasses = await getUpcomingClasses(studentId: targetId);

    final fees = _schoolDataService.getStudentFees(student.id);
    double pendingDues = 0;
    for (var fee in fees) {
      if (fee.status == FeeStatus.pending || fee.status == FeeStatus.overdue) {
        pendingDues += fee.remainingAmount;
      }
    }

    // Calculate pending assignments
    final allAsn = _schoolDataService.getAssignments(schoolId);
    final studentClass = student.classNumber;
    final mySubmitted =
        _schoolDataService.submissions[schoolId]
            ?.where((s) => s.studentId == targetId)
            .map((s) => s.assignmentId)
            .toSet() ??
        {};

    final pendingCount = allAsn
        .where(
          (a) => a.classNumber == studentClass && !mySubmitted.contains(a.id),
        )
        .length;

    // --- FETCH SUBJECTS FOR CLASS ---
    // Strategy 1: Match via SubjectModel (classId or classNumber match)
    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();
    final normalizedStudentClass = normalize(student.classNumber);

    final myClass = _schoolDataService
        .getClassesBySchool(schoolId)
        .firstWhereOrNull((c) => normalize(c.name) == normalizedStudentClass);

    Set<String> subjectNames = {};

    // From SubjectModel linked to class
    if (myClass != null) {
      final fromSubjectModel = _schoolDataService
          .getSubjectsBySchool(schoolId)
          .where((s) => s.classId == myClass.id)
          .map((s) => s.name);
      subjectNames.addAll(fromSubjectModel);
    }

    // Fallback: pull from timetable for this class (handles case where subjects only exist in timetable)
    if (subjectNames.isEmpty) {
      final fromTimetable = _schoolDataService
          .getTimetable(schoolId)
          .where(
            (slot) => normalize(slot.classNumber) == normalizedStudentClass,
          )
          .map((slot) => slot.subjectName)
          .where((n) => n.isNotEmpty);
      subjectNames.addAll(fromTimetable);
    }

    final subjectsForClass = subjectNames.toList()..sort();

    return StudentDashboardData(
      studentName: student.name,
      profilePhoto: student.photoUrl,
      className: student.classNumber,
      section: 'A',
      attendancePercentage: attendancePercentage,
      overallPerformance: overallPerformance,
      todaysClasses: todaysClasses,
      upcomingClasses: upcomingClasses,
      feeSummary: pendingDues > 0
          ? 'Pending: ₹$pendingDues'
          : 'No pending dues',
      pendingAssignmentsCount: pendingCount,
      subjects: subjectsForClass,
    );
  }

  Future<List<StudentClassItem>> getUpcomingClasses({String? studentId}) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _getClassesByDate(tomorrow, studentId: studentId);
  }

  Future<List<StudentClassItem>> getTodayClasses({String? studentId}) async {
    return _getClassesByDate(DateTime.now(), studentId: studentId);
  }

  Future<List<StudentClassItem>> _getClassesByDate(
    DateTime date, {
    String? studentId,
  }) async {
    final targetId = studentId ?? _currentUserId;
    _validateSession(targetStudentId: studentId);

    final schoolId = _schoolId;
    if (schoolId == null) return [];

    final student = _schoolDataService
        .getStudentsBySchool(schoolId)
        .firstWhereOrNull((s) => s.id == targetId);

    if (student == null) return [];

    final fullTimetable = _schoolDataService.getTimetable(schoolId);
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final targetDayMain = days[date.weekday - 1].toLowerCase();
    final targetDayShort = targetDayMain.substring(0, 3);

    String normalizeClass(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();
    final targetSlots = fullTimetable.where((slot) {
      final slotDay = slot.day.trim().toLowerCase();
      final classMatch =
          normalizeClass(slot.classNumber) ==
          normalizeClass(student.classNumber);
      final dayMatch = slotDay == targetDayMain || slotDay == targetDayShort;
      return classMatch && dayMatch;
    }).toList();

    return targetSlots
        .map(
          (slot) => StudentClassItem(
            subject: slot.subjectName,
            teacherName: slot.teacherName,
            startTime: slot.startTime,
            endTime: slot.endTime,
            room: slot.roomNumber,
          ),
        )
        .toList();
  }
}
