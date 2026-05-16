import 'package:get/get.dart';
import '../../../services/firestore_helper.dart';
import '../../../services/auth_service.dart';
import '../../../services/teacher_service.dart';
import '../../../services/school_data_service.dart';
import '../../../models/pending_operation.dart';
import '../../school_admin/models/school_admin_models.dart';
import '../../../data/models/user_session.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/messaging/message_model.dart';

import '../../../data/models/exam_model.dart';
import '../../../data/models/academic_attendance_model.dart' as academic;
import '../models/teacher_dashboard_models.dart';

class TeacherDashboardService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final SchoolDataService _schoolDataService = Get.find<SchoolDataService>();
  final TeacherService _teacherService = Get.find<TeacherService>();

  final isOffline = false.obs;

  // Reactive State
  final teacherTimetable = <ClassTimetableSlotModel>[].obs;
  final teacherExams = <UnifiedExamModel>[].obs;

  String get userId => _authService.session.value?.userId ?? '';

  void setupExamsListener() {
    final session = _authService.session.value;
    if (session?.schoolId != null) {
      final list = _schoolDataService.exams[session!.schoolId!];
      if (list != null) {
        ever(list, (_) => fetchTeacherExams());
      }
    }
    fetchTeacherExams();
  }

  void setupTimetableListener() {
    final session = _authService.session.value;
    if (session?.schoolId != null) {
      final tList = _schoolDataService.timetables[session!.schoolId!];
      if (tList != null) {
        ever(tList, (_) => fetchTeacherTimetable());
      }

      final aList = _schoolDataService.teacherAssignments[session.schoolId!];
      if (aList != null) {
        // We can't directly trigger timetable fetch for assignments, but we want
        // to notify listeners that things might have changed.
        // For simplicity, we just trigger fetchTeacherTimetable if assigned classes are needed.
        ever(aList, (_) => fetchTeacherTimetable());
      }
    }
    fetchTeacherTimetable();
  }

  void fetchTeacherExams() {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return;

    final exams = _schoolDataService.getTeacherExams(
      session.schoolId!,
      session.userId,
    );
    teacherExams.assignAll(exams);
  }

  UserSession _getSessionOrThrow() {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) {
      throw 'No active session or school ID';
    }
    return session;
  }

  Future<TeacherDashboardData> getDashboardData() async {
    final session = _getSessionOrThrow();
    // Fetch fresh profile from service instead of just session
    final teacher = await _teacherService.findTeacherByEmail(
      session.email ?? '',
    );
    if (teacher == null) throw 'Teacher profile not found';
    await fetchTeacherTimetable();

    final classesCount = teacher.subjectsTaught.length;
    final stats = TeacherStats(
      totalStudents: fetchStudentCounts(),
      totalClasses: classesCount,
      pendingAssignments: filterAssignments(completed: false).length,
    );

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final now = DateTime.now();
    final todayName = days[now.weekday - 1].toLowerCase();
    final todayShort = todayName.substring(0, 3);

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowName = days[tomorrow.weekday - 1].toLowerCase();
    final tomorrowShort = tomorrowName.substring(0, 3);

    final school = _schoolDataService.getSchool(session.schoolId!);

    return TeacherDashboardData(
      teacherProfile: teacher,
      todayTimetable: teacherTimetable.where((slot) {
        final d = slot.day.trim().toLowerCase();
        return d == todayName || d == todayShort;
      }).toList(),
      upcomingTimetable: teacherTimetable.where((slot) {
        final d = slot.day.trim().toLowerCase();
        return d == tomorrowName || d == tomorrowShort;
      }).toList(),
      stats: stats,
      schoolName: school?.name ?? session.schoolId ?? 'My School',
      rating: 4.8,
    );
  }

  void setOfflineMode(bool value) {
    isOffline.value = value;
    _schoolDataService.isOffline.value = value;
  }

  Future<void> updateTeacherFields({
    String? name,
    String? contact,
    String? address,
    String? qualification,
    String? bloodGroup,
  }) async {
    final session = _getSessionOrThrow();
    final currentTeacher = await _teacherService.findTeacherByEmail(
      session.email ?? '',
    );
    if (currentTeacher == null) throw 'Teacher profile not found';
    if (currentTeacher.id != session.userId) throw 'Session Mismatch';

    final updatedTeacher = currentTeacher.copyWith(
      name: name,
      contactNumber: contact,
      address: address,
      qualification: qualification,
      bloodGroup: bloodGroup,
      updatedAt: DateTime.now(),
      qualifications: !currentTeacher.qualifications.contains(qualification)
          ? [...currentTeacher.qualifications, qualification!]
          : currentTeacher.qualifications,
    );

    _teacherService.updateTeacher(session.schoolId!, updatedTeacher);
  }

  List<NotificationModel> fetchNotifications() {
    final session = _getSessionOrThrow();
    return _schoolDataService.getNotifications(
      session.schoolId!,
      session.userId,
    );
  }

  void markNotificationAsRead(String notificationId) {
    final session = _getSessionOrThrow();
    final list = _schoolDataService.notifications[session.schoolId!];
    if (list != null) {
      final index = list.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        /* Logic */
      }
    }
  }

  void simulateNotification(
    String title,
    String message,
    NotificationType type,
  ) {
    final session = _getSessionOrThrow();
    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      audience: NotificationAudience.teachers,
      targetId: session.userId,
    );
    _schoolDataService.notifications[session.schoolId!]?.add(notification);
  }

  Future<void> syncUpdates() async =>
      await _schoolDataService.syncPendingUpdates();
  Future<void> syncPendingUpdates() async =>
      await _schoolDataService.syncPendingUpdates();
  int getPendingCount() => _schoolDataService.pendingOperations.length;

  Map<String, dynamic> fetchAttendanceSummary() {
    final session = _getSessionOrThrow();
    final allAttendance =
        _schoolDataService.subjectAttendance[session.schoolId!] ?? [];

    // Filter attendance records where this teacher was the one marking
    final teacherAttendance = allAttendance
        .where((r) => r.teacherId == session.userId)
        .toList();

    if (teacherAttendance.isEmpty) {
      return {'overallPercentage': 0.0, 'classBreakdown': {}};
    }

    // Group by classId
    final Map<String, List<academic.SubjectAttendanceRecord>> groupedByClass =
        {};
    for (var r in teacherAttendance) {
      groupedByClass.putIfAbsent(r.classId, () => []).add(r);
    }

    final Map<String, double> classBreakdown = {};
    int totalPresent = 0;
    int totalCount = 0;

    groupedByClass.forEach((classId, records) {
      final present = records
          .where((r) => r.status == academic.SubjectAttendanceStatus.present)
          .length;
      final percentage = records.isNotEmpty ? present / records.length : 0.0;
      classBreakdown[classId] = percentage;

      totalPresent += present;
      totalCount += records.length;
    });

    return {
      'overallPercentage': totalCount > 0 ? totalPresent / totalCount : 0.0,
      'classBreakdown': classBreakdown,
    };
  }

  Map<String, dynamic> fetchAssignmentCompletion() {
    final session = _getSessionOrThrow();
    final allAssignments = _schoolDataService.getAssignments(
      session.schoolId!,
      session.userId,
    );

    int totalExpected = 0;
    int totalSubmitted = 0;
    int pendingCount = 0;

    for (var a in allAssignments) {
      totalExpected += a.totalStudents;
      totalSubmitted += a.submissionCount;
      if (!a.isCompleted) {
        pendingCount++;
      }
    }

    final completionRate = totalExpected > 0
        ? totalSubmitted / totalExpected
        : 0.0;

    return {
      'completionRate': completionRate,
      'count': allAssignments.length,
      'pendingCount': pendingCount,
    };
  }

  int fetchStudentCounts() {
    final session = _getSessionOrThrow();
    // Get unique classes this teacher interacts with
    final classes = filterTimetable().map((s) => s.classNumber).toSet();

    // Also check assigned classes
    final assigned = getAssignedClasses();
    for (var a in assigned) {
      classes.add(a.classNumber);
    }

    if (classes.isEmpty) return 0;

    int count = 0;
    final allStudents = _schoolDataService.getStudentsBySchool(
      session.schoolId!,
    );

    for (var cls in classes) {
      count += allStudents.where((s) => s.classNumber == cls).length;
    }

    return count;
  }

  final _localSettings = TeacherSettingsModel().obs;
  TeacherSettingsModel fetchSettings() => _localSettings.value;
  void updateSettings(TeacherSettingsModel settings) =>
      _localSettings.value = settings;

  Future<void> fetchTeacherTimetable() async {
    final session = _getSessionOrThrow();
    final allSlots = _schoolDataService.getTeacherTimetable(
      session.schoolId!,
      session.userId,
    );
    teacherTimetable.assignAll(allSlots);
  }

  List<TeacherAssignmentModel> getAssignedClasses() {
    final session = _authService.session.value;
    if (session == null || session.schoolId == null) return [];

    return _schoolDataService
        .getTeacherAssignmentsBySchool(session.schoolId!)
        .where((a) => a.teacherId == session.userId)
        .toList();
  }

  List<ClassTimetableSlotModel> filterTimetable({
    String? day,
    String? subject,
    String? classId,
  }) {
    if (teacherTimetable.isEmpty && !isOffline.value) fetchTeacherTimetable();
    return teacherTimetable.where((slot) {
      bool matches = true;
      if (day != null && day.isNotEmpty) matches = matches && slot.day == day;
      if (subject != null && subject.isNotEmpty) {
        matches =
            matches &&
            slot.subjectName.toLowerCase().contains(subject.toLowerCase());
      }
      if (classId != null && classId.isNotEmpty) {
        final cleanClassId = classId.replaceAll('Class ', '');
        matches = matches && slot.classNumber == cleanClassId;
      }
      return matches;
    }).toList();
  }

  void addTimetableEntry(ClassTimetableSlotModel slot) {
    final session = _getSessionOrThrow();
    _schoolDataService.timetables[session.schoolId!]?.add(slot);
    teacherTimetable.add(slot);
    if (isOffline.value) {
      _schoolDataService.pendingOperations.add(
        PendingOperation(
          id: slot.id,
          type: OperationType.add,
          entityType: EntityType.timetable,
          data: {'slot': slot},
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void updateTimetableEntry(ClassTimetableSlotModel slot) {
    final session = _getSessionOrThrow();
    final list = _schoolDataService.timetables[session.schoolId!];
    if (list != null) {
      final index = list.indexWhere((s) => s.id == slot.id);
      if (index != -1) {
        list[index] = slot;
        final localIndex = teacherTimetable.indexWhere((s) => s.id == slot.id);
        if (localIndex != -1) teacherTimetable[localIndex] = slot;
      }
    }
  }

  void deleteTimetableEntry(String id) {
    final session = _getSessionOrThrow();
    _schoolDataService.timetables[session.schoolId!]?.removeWhere(
      (s) => s.id == id,
    );
    teacherTimetable.removeWhere((s) => s.id == id);
  }

  List<AssignmentModel> filterAssignments({String? classId, bool? completed}) {
    final session = _getSessionOrThrow();
    final allAssignments = _schoolDataService.getAssignments(
      session.schoolId!,
      session.userId,
    );
    var filtered = allAssignments;
    if (classId != null && classId.isNotEmpty) {
      filtered = filtered.where((a) => a.classNumber == classId).toList();
    }
    if (completed != null) {
      filtered = filtered.where((a) => a.isCompleted == completed).toList();
    }
    return filtered;
  }

  void createAssignment(AssignmentModel assignment) {
    final session = _getSessionOrThrow();
    _schoolDataService.assignments[session.schoolId!]?.add(assignment);
  }

  Future<List<StudentModel>> getStudentsForClass(String classId) async {
    final session = _getSessionOrThrow();
    final students =
        _schoolDataService.getStudentsForClass(session.schoolId!, classId);
    return students.where((s) => s.canStudentLogin && !s.isStruckOff).toList();
  }

  Future<List<StudentModel>> searchStudents(
    String query, {
    String? classId,
  }) async {
    final session = _getSessionOrThrow();
    var students = _schoolDataService.students[session.schoolId!] ?? [];

    // Filter by Active Status First
    var list =
        students.where((s) => s.canStudentLogin && !s.isStruckOff).toList();

    if (classId != null && classId.isNotEmpty) {
      final target = classId.toLowerCase().replaceAll('class ', '').trim();
      list = list.where((s) {
        final sc = s.classNumber.toLowerCase().replaceAll('class ', '').trim();
        return s.classId == classId || sc == target;
      }).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return list.cast<StudentModel>();
  }

  Future<void> sendMessageToAdmin(String content) async {
    final session = _getSessionOrThrow();
    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: session.schoolId!,
      senderId: session.userId,
      senderRole: UserRole.teacher,
      receiverId: 'admin_1',
      receiverRole: UserRole.schoolAdmin,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _schoolDataService.messages[session.schoolId!]?.add(message);
  }

  List<MessageModel> fetchInbox() {
    final session = _getSessionOrThrow();
    final all = _schoolDataService.messages[session.schoolId!] ?? [];
    return all
        .where(
          (m) => m.senderId == session.userId || m.receiverId == session.userId,
        )
        .toList()
        .cast<MessageModel>();
  }

  List<MessageModel> fetchConversation(String receiverId) {
    final session = _getSessionOrThrow();
    final all = _schoolDataService.messages[session.schoolId!] ?? [];
    return all
        .where(
          (m) =>
              (m.senderId == session.userId && m.receiverId == receiverId) ||
              (m.senderId == receiverId && m.receiverId == session.userId),
        )
        .toList()
        .cast<MessageModel>();
  }

  void markAsRead(String messageId) {
    final session = _getSessionOrThrow();
    _schoolDataService.markMessageAsRead(session.schoolId!, messageId);
  }

  Future<void> exportTimetable() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> exportStudentList(String classId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> exportAnalyticsReport() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> sendMessageToParent({
    required String studentId,
    required String content,
  }) async {
    final session = _getSessionOrThrow();
    final message = MessageModel(
      id: 'msg_p_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: session.schoolId!,
      senderId: session.userId,
      senderRole: UserRole.teacher,
      receiverId: 'parent_$studentId',
      receiverRole: UserRole.parent,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _schoolDataService.messages[session.schoolId!]?.add(message);
  }

  Future<void> addStudentToClass(String classId, StudentModel student) async {
    final session = _getSessionOrThrow();
    final schoolId = session.schoolId!;

    // 1. Add to School's Student collection
    await _schoolDataService.addStudent(schoolId, student);

    // 2. Add to Classroom (Optional: if we have a separate classroom/students link)
    // For this app, classNumber is a field in StudentModel.
    // So usually addStudent is enough.
  }

  Future<void> removeStudentFromClass(String classId, String studentId) async {
    final session = _getSessionOrThrow();
    final schoolId = session.schoolId!;

    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('students')
        .doc(studentId)
        .delete();
  }
}
