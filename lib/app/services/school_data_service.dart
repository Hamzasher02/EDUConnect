import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helper.dart';
import '../data/models/exam_model.dart';
import '../data/models/assignment_model.dart';
import '../data/models/attendance_record_model.dart';
import '../data/models/result_model.dart';
import '../data/models/academic_result_model.dart';
import '../data/models/academic_attendance_model.dart';
import '../modules/school_admin/models/school_admin_models.dart';
import '../modules/dashboard/models/school_model.dart';
import '../data/models/messaging/message_model.dart';
import '../data/models/submission_model.dart';
import '../models/pending_operation.dart';

class SchoolDataService extends GetxService {
  static SchoolDataService get to => Get.find<SchoolDataService>();

  final RxMap<String, Map<String, dynamic>> schoolsData =
      <String, Map<String, dynamic>>{}.obs;

  // Public RxMaps for all core data types
  final RxMap<String, RxList<ClassModel>> classes =
      <String, RxList<ClassModel>>{}.obs;
  final RxMap<String, RxList<StudentModel>> students =
      <String, RxList<StudentModel>>{}.obs;
  final RxMap<String, RxList<TeacherModel>> teachers =
      <String, RxList<TeacherModel>>{}.obs;
  final RxMap<String, RxList<ClassTimetableSlotModel>> timetables =
      <String, RxList<ClassTimetableSlotModel>>{}.obs;
  final RxMap<String, RxList<AssignmentModel>> assignments =
      <String, RxList<AssignmentModel>>{}.obs;
  final RxMap<String, RxList<AttendanceRecordModel>> attendance =
      <String, RxList<AttendanceRecordModel>>{}.obs;
  final RxMap<String, RxList<ResultModel>> results =
      <String, RxList<ResultModel>>{}.obs;
  final RxMap<String, RxList<AcademicResultModel>> academicResults =
      <String, RxList<AcademicResultModel>>{}.obs;
  final RxMap<String, RxList<SubjectAttendanceRecord>> subjectAttendance =
      <String, RxList<SubjectAttendanceRecord>>{}.obs;
  final RxMap<String, RxList<UnifiedExamModel>> exams =
      <String, RxList<UnifiedExamModel>>{}.obs;
  final RxMap<String, RxList<MessageModel>> messages =
      <String, RxList<MessageModel>>{}.obs;
  final RxMap<String, RxList<SubmissionModel>> submissions =
      <String, RxList<SubmissionModel>>{}.obs;
  final RxMap<String, RxList<NotificationModel>> notifications =
      <String, RxList<NotificationModel>>{}.obs;
  final RxMap<String, RxList<FeeRecordModel>> fees =
      <String, RxList<FeeRecordModel>>{}.obs;
  final RxMap<String, RxList<SubjectModel>> subjects =
      <String, RxList<SubjectModel>>{}.obs;
  final RxMap<String, RxList<TeacherAssignmentModel>> teacherAssignments =
      <String, RxList<TeacherAssignmentModel>>{}.obs;
  final RxMap<String, RxList<ExamScheduleModel>> examSchedules =
      <String, RxList<ExamScheduleModel>>{}.obs;

  // Global Lookups
  final _teacherSettings = <String, TeacherSettingsModel>{}.obs;

  // Connectivity & Sync Properties
  final RxBool isOffline = false.obs;
  final RxList<PendingOperation> pendingOperations = <PendingOperation>[].obs;

  List<String> get schoolIds => schoolsData.keys.toList();

  @override
  void onInit() {
    super.onInit();
    _initStreams();
  }

  void _initStreams() {
    FirestoreHelper.schools.snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final schoolId = doc.id;
        schoolsData[schoolId] = doc.data() as Map<String, dynamic>;
        _bindSubStreams(schoolId);
      }
    });
  }

  void _bindSubStreams(String schoolId) {
    if (classes.containsKey(schoolId)) return;

    void bind<T>(
      Query query,
      RxList<T> target,
      T Function(Map<String, dynamic> json, String id) fromJson,
    ) {
      query.snapshots().listen((snapshot) {
        target.value = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return fromJson(data, doc.id);
        }).toList();
      });
    }

    classes[schoolId] = <ClassModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('classes'),
      classes[schoolId]!,
      (json, id) => ClassModel.fromJson(json..['id'] = id),
    );

    students[schoolId] = <StudentModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('students'),
      students[schoolId]!,
      (json, id) => StudentModel.fromJson(json..['id'] = id),
    );

    teachers[schoolId] = <TeacherModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('teachers'),
      teachers[schoolId]!,
      (json, id) => TeacherModel.fromJson(json..['id'] = id),
    );

    timetables[schoolId] = <ClassTimetableSlotModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('timetables'),
      timetables[schoolId]!,
      (json, id) => ClassTimetableSlotModel(
        id: id,
        classId: json['classId'] ?? json['classNumber'] ?? '',
        classNumber: json['classNumber'] ?? '',
        day: json['day'] ?? '',
        subjectId: json['subjectId'] ?? json['subjectName'] ?? '',
        subjectName: json['subjectName'] ?? '',
        teacherId: json['teacherId'],
        teacherName: json['teacherName'] ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        roomNumber: json['roomNumber'] ?? '',
      ),
    );

    assignments[schoolId] = <AssignmentModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('assignments'),
      assignments[schoolId]!,
      (json, id) => AssignmentModel.fromJson(json..['id'] = id),
    );

    attendance[schoolId] = <AttendanceRecordModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('attendance'),
      attendance[schoolId]!,
      (json, id) => AttendanceRecordModel.fromJson(json..['id'] = id),
    );

    submissions[schoolId] = <SubmissionModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('submissions'),
      submissions[schoolId]!,
      (json, id) => SubmissionModel.fromJson(json..['id'] = id),
    );

    results[schoolId] = <ResultModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('results'),
      results[schoolId]!,
      (json, id) => ResultModel.fromJson(json..['id'] = id),
    );

    academicResults[schoolId] = <AcademicResultModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('academic_results'),
      academicResults[schoolId]!,
      (json, id) => AcademicResultModel.fromJson(json..['id'] = id),
    );

    subjectAttendance[schoolId] = <SubjectAttendanceRecord>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('subject_attendance'),
      subjectAttendance[schoolId]!,
      (json, id) => SubjectAttendanceRecord.fromJson(json..['id'] = id),
    );

    exams[schoolId] = <UnifiedExamModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('exams'),
      exams[schoolId]!,
      (json, id) => UnifiedExamModel.fromJson(json..['id'] = id),
    );

    messages[schoolId] = <MessageModel>[].obs;
    bind(
      FirestoreHelper.messages.where('schoolId', isEqualTo: schoolId),
      messages[schoolId]!,
      (json, id) => MessageModel.fromJson(json..['id'] = id),
    );

    // Already bound correctly as sub-collection on line 152

    notifications[schoolId] = <NotificationModel>[].obs;
    bind(
      FirestoreHelper.notifications.where('schoolId', isEqualTo: schoolId),
      notifications[schoolId]!,
      (json, id) => NotificationModel.fromJson(json..['id'] = id),
    );

    fees[schoolId] = <FeeRecordModel>[].obs;
    bind(
      FirestoreHelper.fees.where('schoolId', isEqualTo: schoolId),
      fees[schoolId]!,
      (json, id) => FeeRecordModel.fromJson(json..['id'] = id),
    );

    subjects[schoolId] = <SubjectModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('subjects'),
      subjects[schoolId]!,
      (json, id) => SubjectModel.fromJson(json..['id'] = id),
    );

    teacherAssignments[schoolId] = <TeacherAssignmentModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('teacherAssignments'),
      teacherAssignments[schoolId]!,
      (json, id) => TeacherAssignmentModel.fromJson(json..['id'] = id),
    );

    examSchedules[schoolId] = <ExamScheduleModel>[].obs;
    bind(
      FirestoreHelper.schools.doc(schoolId).collection('exam_schedules'),
      examSchedules[schoolId]!,
      (json, id) => ExamScheduleModel.fromJson(json..['id'] = id),
    );
  }

  // --- GETTERS ---

  List<ClassModel> getClassesBySchool(String schoolId) =>
      classes[schoolId] ?? [];
  List<StudentModel> getStudentsBySchool(String schoolId) =>
      students[schoolId] ?? [];
  List<TeacherModel> getTeachersBySchool(String schoolId) =>
      teachers[schoolId] ?? [];
  List<ClassTimetableSlotModel> getTimetable(String schoolId) =>
      timetables[schoolId] ?? [];
  List<AssignmentModel> getAssignmentsBySchool(String schoolId) =>
      assignments[schoolId] ?? [];
  List<AttendanceRecordModel> getAttendanceBySchool(String schoolId) =>
      attendance[schoolId] ?? [];
  List<ResultModel> getResultsBySchool(String schoolId) =>
      results[schoolId] ?? [];
  List<ResultModel> getResultsForClass(
    String schoolId,
    String classId,
    String subject,
  ) {
    return getResultsBySchool(schoolId)
        .where((r) => r.classId == classId && r.subject == subject)
        .toList();
  }

  List<ResultModel> getResultsForStudent(String schoolId, String studentId) {
    return getResultsBySchool(schoolId)
        .where((r) => r.studentId == studentId)
        .toList();
  }

  List<UnifiedExamModel> getExamsBySchool(String schoolId) =>
      exams[schoolId] ?? [];

  List<MessageModel> getMessagesBySchool(String schoolId) =>
      messages[schoolId] ?? [];
  List<SubmissionModel> getSubmissionsBySchool(String schoolId) =>
      submissions[schoolId] ?? [];
  List<NotificationModel> getNotificationsBySchool(String schoolId) =>
      notifications[schoolId] ?? [];
  List<NotificationModel> getNotificationsForSchool(String schoolId) =>
      getNotificationsBySchool(schoolId);
  List<FeeRecordModel> getFeesBySchool(String schoolId) => fees[schoolId] ?? [];
  List<FeeRecordModel> getFeeRecords(String schoolId) =>
      getFeesBySchool(schoolId);
  List<SubjectModel> getSubjectsBySchool(String schoolId) =>
      subjects[schoolId] ?? [];
  List<TeacherAssignmentModel> getTeacherAssignmentsBySchool(String schoolId) =>
      teacherAssignments[schoolId] ?? [];

  // Compatibility aliases
  SchoolModel? getSchool(String schoolId) {
    final schoolData = schoolsData[schoolId];
    if (schoolData != null) {
      return SchoolModel.fromJson(schoolData);
    }
    return null;
  }

  List<ClassModel> getClasses(String schoolId) => getClassesBySchool(schoolId);
  List<TeacherModel> getTeachers(String schoolId) =>
      getTeachersBySchool(schoolId);
  List<StudentModel> getStudents(String schoolId) =>
      getStudentsBySchool(schoolId);
  List<StudentModel> getStudentsByClass(String schoolId, String classNumber) =>
      getStudentsForClass(schoolId, classNumber);

  Map<String, dynamic>? getStudentProfile(String studentId) {
    for (var schoolList in students.values) {
      final student = schoolList.firstWhereOrNull((s) => s.id == studentId);
      if (student != null) {
        return student.toJson();
      }
    }
    return null;
  }

  List<AssignmentModel> getAssignments(String schoolId, [String? teacherId]) {
    final list = getAssignmentsBySchool(schoolId);
    if (teacherId != null) {
      return list.where((a) => a.teacherId == teacherId).toList();
    }
    return list;
  }

  List<NotificationModel> getNotifications(
    String schoolId, [
    String? targetId,
  ]) {
    final list = getNotificationsBySchool(schoolId);
    if (targetId != null) {
      return list
          .where(
            (n) =>
                n.targetId == targetId ||
                n.audience == NotificationAudience.wholeSchool,
          )
          .toList();
    }
    return list;
  }

  // --- Specialized Lookups ---

  List<ClassTimetableSlotModel> getTeacherTimetable(
    String schoolId,
    String teacherId,
  ) {
    return getTimetable(
      schoolId,
    ).where((s) => s.teacherId == teacherId).toList();
  }

  List<StudentModel> getStudentsForClass(String schoolId, String classNumber) {
    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();
    final target = normalize(classNumber);

    return getStudentsBySchool(
      schoolId,
    ).where((s) => normalize(s.classNumber) == target).toList();
  }

  // --- Student-Facing Optimized Getters ---

  List<AttendanceRecordModel> getStudentAttendance(
    String studentId, {
    int? month,
  }) {
    final List<AttendanceRecordModel> records = [];

    // Add legacy attendance
    for (var list in attendance.values) {
      records.addAll(list.where((a) => a.studentId == studentId));
    }

    // Add new subject attendance mapped to the unified model
    for (var list in subjectAttendance.values) {
      for (var subAtt in list.where((a) => a.studentId == studentId)) {
        records.add(
          AttendanceRecordModel(
            id: subAtt.id,
            studentId: subAtt.studentId,
            studentName: subAtt.studentName,
            rollNo: 'N/A', // Not stored in subject attendance yet
            classId: subAtt.classId,
            subject: subAtt.subjectId,
            date: subAtt.date,
            status: subAtt.status.name == 'present'
                ? AttendanceStatus.present
                : (subAtt.status.name == 'absent'
                      ? AttendanceStatus.absent
                      : AttendanceStatus.leave),
            recordedBy: subAtt.teacherId,
          ),
        );
      }
    }

    if (month != null) {
      return records.where((a) => a.date.month == month).toList();
    }
    return records;
  }

  List<ResultModel> getStudentResults(String studentId) {
    final List<ResultModel> records = [];
    for (var list in results.values) {
      records.addAll(list.where((r) => r.studentId == studentId));
    }
    return records;
  }

  List<AcademicResultModel> getStudentAcademicResults(String studentId) {
    final List<AcademicResultModel> records = [];
    for (var list in academicResults.values) {
      records.addAll(list.where((r) => r.studentId == studentId));
    }
    return records;
  }

  List<SubmissionModel> getStudentSubmissions(String studentId) {
    final List<SubmissionModel> records = [];
    for (var list in submissions.values) {
      records.addAll(list.where((s) => s.studentId == studentId));
    }
    return records;
  }

  List<MessageModel> getStudentMessages(String studentId) {
    final all = <MessageModel>[];
    for (var list in messages.values) {
      all.addAll(list);
    }
    return all
        .where((m) => m.receiverId == studentId || m.senderId == studentId)
        .toList();
  }

  List<NotificationModel> getStudentAnnouncements(
    String schoolId,
    String classNumber,
  ) {
    final list = notifications[schoolId] ?? <NotificationModel>[].obs;
    return list
        .where(
          (n) =>
              n.type == NotificationType.announcement &&
              (n.audience == NotificationAudience.wholeSchool ||
                  n.targetId == classNumber),
        )
        .toList();
  }

  List<NotificationModel> getStudentNotifications(
    String schoolId,
    String studentId,
  ) {
    final list = notifications[schoolId] ?? <NotificationModel>[].obs;
    return list
        .where(
          (n) =>
              n.targetId == studentId ||
              n.audience == NotificationAudience.wholeSchool ||
              n.audience == NotificationAudience.students,
        )
        .toList();
  }

  // --- Notification Actions ---

  Future<void> markNotificationAsRead(
    String schoolId,
    String notificationId,
  ) async {
    final list = notifications[schoolId];
    if (list != null) {
      final index = list.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !list[index].isRead) {
        final updated = list[index].copyWith(isRead: true);
        list[index] = updated;

        // Update in Firestore
        await FirestoreHelper.notifications.doc(notificationId).update({
          'isRead': true,
        });
      }
    }
  }

  int getUnreadNotificationCount(
    String schoolId,
    String userId, {
    String? classNumber,
    NotificationAudience? roleAudience,
  }) {
    final list = notifications[schoolId] ?? [];
    return list.where((n) {
      if (n.isRead) return false;

      // Match specific target (personal ID or class ID)
      if (n.targetId == userId) return true;
      if (classNumber != null && n.targetId == classNumber) return true;

      // Match broad audience
      if (n.audience == NotificationAudience.wholeSchool) return true;
      if (roleAudience != null && n.audience == roleAudience) return true;

      return false;
    }).length;
  }

  // --- Message Actions ---

  Future<void> markMessageAsRead(String schoolId, String messageId) async {
    final list = messages[schoolId];
    if (list != null) {
      final index = list.indexWhere((m) => m.id == messageId);
      if (index != -1 && !list[index].isRead) {
        final updated = list[index].copyWith(isRead: true);
        list[index] = updated;

        // Update in Firestore
        await FirestoreHelper.messages.doc(messageId).update({'isRead': true});
      }
    }
  }

  int getUnreadMessageCount(String schoolId, String userId) {
    final list = messages[schoolId] ?? [];
    return list.where((m) => m.receiverId == userId && !m.isRead).length;
  }

  List<UnifiedExamModel> getStudentExams(String studentId, [String? schoolId]) {
    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();

    // If we have schoolId, search there first for efficiency
    if (schoolId != null) {
      final list = students[schoolId];
      if (list != null) {
        final student = list.firstWhereOrNull((s) => s.id == studentId);
        if (student != null) {
          final classNum = normalize(student.classNumber);
          return (exams[schoolId] ?? <UnifiedExamModel>[]).where((e) {
            return normalize(e.classNumber) == classNum;
          }).toList();
        }
      }
    }

    // Fallback search across all (legacy or cross-school lookups)
    for (var schoolKey in students.keys) {
      final list = students[schoolKey]!;
      final student = list.firstWhereOrNull((s) => s.id == studentId);
      if (student != null) {
        final classNum = normalize(student.classNumber);
        return (exams[schoolKey] ?? <UnifiedExamModel>[]).where((e) {
          return normalize(e.classNumber) == classNum;
        }).toList();
      }
    }
    return [];
  }

  List<UnifiedExamModel> getTeacherExams(String schoolId, String teacherId) {
    // 1. Get all classes and subjects this teacher teaches
    final teacherSlots = getTeacherTimetable(schoolId, teacherId);
    final assignments = getTeacherAssignmentsBySchool(
      schoolId,
    ).where((a) => a.teacherId == teacherId);

    String normalize(String s) =>
        s.toLowerCase().replaceAll('class ', '').trim();

    final Set<String> matchingKeys = {}; // "classNumber|subjectName"

    // From Timetable
    for (var slot in teacherSlots) {
      matchingKeys.add(
        '${normalize(slot.classNumber)}|${slot.subjectName.trim().toLowerCase()}',
      );
    }

    // From Direct Assignments
    for (var a in assignments) {
      matchingKeys.add(
        '${normalize(a.classNumber)}|${a.subjectName.trim().toLowerCase()}',
      );
    }

    // 2. Filter exams that match those keys
    return (exams[schoolId] ?? <UnifiedExamModel>[]).where((e) {
      final key =
          '${normalize(e.classNumber)}|${e.subject.trim().toLowerCase()}';
      return matchingKeys.contains(key);
    }).toList();
  }

  List<FeeRecordModel> getStudentFees(String studentId) {
    final List<FeeRecordModel> records = [];
    for (var list in fees.values) {
      records.addAll(list.where((f) => f.studentId == studentId));
    }
    return records;
  }

  // Placeholder - already implemented above

  // --- ACTIONS ---

  Future<String> addStudent(String schoolId, StudentModel student) async {
    // 1. Check for duplicate roll no in the same class
    final existing = students[schoolId]?.firstWhereOrNull(
      (s) => s.classNumber == student.classNumber && s.rollNo == student.rollNo,
    );
    if (existing != null) {
      throw 'Roll No ${student.rollNo} already exists in Class ${student.classNumber}';
    }

    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('students')
        .doc(student.id.isEmpty ? null : student.id);

    // Ensure the ID is set in the saved data
    final data = student.toJson();
    data['id'] = docRef.id;

    await docRef.set(data);

    // 2. Increment student count in school doc
    await FirestoreHelper.schools.doc(schoolId).update({
      'studentCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  Future<void> addNotification(
    String schoolId,
    NotificationModel notification,
  ) async {
    // Write to the GLOBAL notifications collection (not sub-collection)
    // so that the stream bound to FirestoreHelper.notifications can read it.
    final docRef = FirestoreHelper.notifications.doc(
      notification.id.isEmpty ? null : notification.id,
    );
    final data = notification.toJson();
    data['id'] = docRef.id;
    data['schoolId'] = schoolId; // Ensure schoolId is on the document
    await docRef.set(data);
  }

  Future<void> addClass(String schoolId, ClassModel classModel) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('classes')
        .doc(classModel.id.isEmpty ? null : classModel.id);

    // Ensure the ID is set in the saved data
    final data = classModel.toJson();
    data['id'] = docRef.id;

    await docRef.set(data);
  }

  Future<void> updateClass(
    String schoolId,
    String oldName,
    ClassModel updatedClass,
  ) async {
    final batch = FirestoreHelper.db.batch();

    // 1. Update the class document
    final classRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('classes')
        .doc(updatedClass.id);
    batch.update(classRef, updatedClass.toJson());

    // 2. If name changed, update all related collections
    if (oldName != updatedClass.name) {
      // Students
      final studentsSnapshot = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('students')
          .where('classNumber', isEqualTo: oldName)
          .get();
      for (var doc in studentsSnapshot.docs) {
        batch.update(doc.reference, {'classNumber': updatedClass.name});
      }

      // Timetables
      final timetableSnapshot = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('timetables')
          .where('classNumber', isEqualTo: oldName)
          .get();
      for (var doc in timetableSnapshot.docs) {
        batch.update(doc.reference, {'classNumber': updatedClass.name});
      }

      // Assignments
      final assignmentSnapshot = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('assignments')
          .where('classNumber', isEqualTo: oldName)
          .get();
      for (var doc in assignmentSnapshot.docs) {
        batch.update(doc.reference, {'classNumber': updatedClass.name});
      }

      // Exams
      final examSnapshot = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('exams')
          .where('classNumber', isEqualTo: oldName)
          .get();
      for (var doc in examSnapshot.docs) {
        batch.update(doc.reference, {'classNumber': updatedClass.name});
      }

      // Subjects (Added for consistency)
      final subjectSnapshot = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('subjects')
          .where('classId', isEqualTo: oldName)
          .get();
      for (var doc in subjectSnapshot.docs) {
        batch.update(doc.reference, {'classId': updatedClass.name});
      }
    }

    await batch.commit();
  }

  Future<void> addAssignment(
    String schoolId,
    AssignmentModel assignment,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('assignments')
        .doc(assignment.id.isEmpty ? null : assignment.id);
    await docRef.set(assignment.toJson()..['id'] = docRef.id);
  }

  Future<void> addSubject(String schoolId, SubjectModel subject) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('subjects')
        .doc(subject.id.isEmpty ? null : subject.id);
    await docRef.set(subject.toJson()..['id'] = docRef.id);
  }

  Future<void> assignTeacherToSubject(
    String schoolId,
    TeacherAssignmentModel assignment,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('teacherAssignments')
        .doc(assignment.id.isEmpty ? null : assignment.id);
    await docRef.set(assignment.toJson()..['id'] = docRef.id);
  }

  Future<void> deleteTeacherAssignment(
    String schoolId,
    String assignmentId,
  ) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('teacherAssignments')
        .doc(assignmentId)
        .delete();
  }

  Future<void> submitAssignment(
    String schoolId,
    SubmissionModel submission,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('submissions')
        .doc(submission.id.isEmpty ? null : submission.id);
    await docRef.set(submission.toJson()..['id'] = docRef.id);

    // Update submission count on assignment
    final assignmentRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('assignments')
        .doc(submission.assignmentId);
    await assignmentRef.update({'submissionCount': FieldValue.increment(1)});
  }

  Future<void> saveAcademicResult(
    String schoolId,
    AcademicResultModel result,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('academic_results')
        .doc(result.id.isEmpty ? null : result.id);
    await docRef.set(result.toJson()..['id'] = docRef.id);
  }

  Future<void> saveSubjectAttendance(
    String schoolId,
    SubjectAttendanceRecord record,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('subject_attendance')
        .doc(record.id.isEmpty ? null : record.id);
    await docRef.set(record.toJson()..['id'] = docRef.id);
  }

  Future<void> gradeSubmission(
    String schoolId,
    SubmissionModel gradedSubmission,
  ) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('submissions')
        .doc(gradedSubmission.id)
        .set(gradedSubmission.toJson());
  }

  List<AssignmentModel> getTeacherAssignments(
    String schoolId,
    String teacherId,
  ) {
    return (assignments[schoolId] ?? <AssignmentModel>[])
        .where((a) => a.teacherId == teacherId)
        .toList();
  }

  List<AssignmentModel> getStudentAssignments(
    String schoolId,
    String classNumber,
  ) {
    return (assignments[schoolId] ?? <AssignmentModel>[])
        .where((a) => a.classNumber == classNumber)
        .toList();
  }

  List<SubmissionModel> getAssignmentSubmissions(
    String schoolId,
    String assignmentId,
  ) {
    return (submissions[schoolId] ?? <SubmissionModel>[])
        .where((s) => s.assignmentId == assignmentId)
        .toList();
  }

  SubmissionModel? getStudentSubmission(
    String schoolId,
    String assignmentId,
    String studentId,
  ) {
    return (submissions[schoolId] ?? <SubmissionModel>[]).firstWhereOrNull(
      (s) => s.assignmentId == assignmentId && s.studentId == studentId,
    );
  }

  Future<void> addTimetableSlot(
    String schoolId,
    ClassTimetableSlotModel slot,
  ) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('timetables')
        .doc(slot.id.isEmpty ? null : slot.id);

    await docRef.set({
      'id': docRef.id,
      'classId': slot.classId,
      'classNumber': slot.classNumber,
      'day': slot.day,
      'subjectId': slot.subjectId,
      'subjectName': slot.subjectName,
      'teacherId': slot.teacherId,
      'teacherName': slot.teacherName,
      'startTime': slot.startTime,
      'endTime': slot.endTime,
      'roomNumber': slot.roomNumber,
    });
  }

  Future<void> updateTimetableSlot(
    String schoolId,
    ClassTimetableSlotModel slot,
  ) => addTimetableSlot(schoolId, slot);

  Future<void> deleteTimetableSlot(String schoolId, String slotId) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('timetables')
        .doc(slotId)
        .delete();
  }

  Future<void> updateStudentProfile(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    await FirestoreHelper.students.doc(studentId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage(String schoolId, MessageModel message) async {
    await FirestoreHelper.messages.add(
      message.toJson()..['timestamp'] = FieldValue.serverTimestamp(),
    );
  }

  Future<void> saveTeacherSettings(
    String teacherId,
    TeacherSettingsModel settings,
  ) async {
    await FirestoreHelper.settings
        .doc(teacherId)
        .set(
          settings.toJson()..['updatedAt'] = FieldValue.serverTimestamp(),
          SetOptions(merge: true),
        );
    _teacherSettings[teacherId] = settings;
  }

  TeacherSettingsModel? getTeacherSettings(String teacherId) =>
      _teacherSettings[teacherId];

  // --- Admin/Teacher Compatibility Actions ---
  Future<String> addTeacher(String schoolId, TeacherModel teacher) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('teachers')
        .doc(teacher.id.isEmpty ? null : teacher.id);

    // Ensure the ID is set in the saved data
    final data = teacher.toJson();
    data['id'] = docRef.id;

    await docRef.set(data);

    // Increment teacher count
    await FirestoreHelper.schools.doc(schoolId).update({
      'teacherCount': FieldValue.increment(1),
    });

    await updateSchoolRankingScore(schoolId);

    return docRef.id;
  }

  Future<void> deleteTeacher(String schoolId, String teacherId) async {
    final batch = FirestoreHelper.db.batch();

    // 1. Delete teacher document
    batch.delete(FirestoreHelper.schools
        .doc(schoolId)
        .collection('teachers')
        .doc(teacherId));

    // 2. Decrement teacher count
    batch.update(FirestoreHelper.schools.doc(schoolId), {
      'teacherCount': FieldValue.increment(-1),
    });

    // 3. Cleanup teacher assignments
    final assignmentSnapshot = await FirestoreHelper.schools
        .doc(schoolId)
        .collection('teacherAssignments')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    for (var doc in assignmentSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 4. Cleanup timetable slots
    final timetableSnapshot = await FirestoreHelper.schools
        .doc(schoolId)
        .collection('timetables')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    for (var doc in timetableSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    await updateSchoolRankingScore(schoolId);
  }

  Future<void> updateTeacher(String schoolId, TeacherModel teacher) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('teachers')
        .doc(teacher.id)
        .update(teacher.toJson());
    await updateSchoolRankingScore(schoolId);
  }

  Future<TeacherModel?> findTeacherByEmailGlobal(String email) async {
    for (var list in teachers.values) {
      final t = list.firstWhereOrNull(
        (t) => t.email.toLowerCase() == email.toLowerCase(),
      );
      if (t != null) return t;
    }
    return null;
  }

  Future<void> addSubmission(SubmissionModel submission) async {
    await FirestoreHelper.submissions.add(
      submission.toJson()..['timestamp'] = FieldValue.serverTimestamp(),
    );
  }

  Future<void> addAttendanceBatch(
    String schoolId,
    List<AttendanceRecordModel> records,
  ) async {
    final batch = FirestoreHelper.db.batch();
    for (var record in records) {
      final docRef = FirestoreHelper.schools
          .doc(schoolId)
          .collection('attendance')
          .doc(record.id);
      batch.set(docRef, record.toJson());
    }
    await batch.commit();

    await updateSchoolRankingScore(schoolId);
  }

  Future<void> addResultsBatch(
    String schoolId,
    List<ResultModel> records,
  ) async {
    final batch = FirestoreHelper.db.batch();
    for (var record in records) {
      final docRef = FirestoreHelper.schools
          .doc(schoolId)
          .collection('results')
          .doc(record.id.isEmpty ? null : record.id);
      batch.set(docRef, record.toJson()..['id'] = docRef.id);
    }
    await batch.commit();

    await updateSchoolRankingScore(schoolId);
  }

  Future<void> updateFeeRecord(String schoolId, FeeRecordModel record) async {
    await FirestoreHelper.fees.doc(record.id).update(record.toJson());
  }

  Future<void> addFeeRecordsBatch(
    String schoolId,
    List<FeeRecordModel> records,
  ) async {
    final batch = FirestoreHelper.db.batch();
    for (var record in records) {
      final docRef = FirestoreHelper.fees.doc(
        record.id.isEmpty ? null : record.id,
      );
      batch.set(docRef, record.toJson()..['id'] = docRef.id);
    }
    await batch.commit();
  }

  Future<void> addFeeRecord(String schoolId, FeeRecordModel record) async {
    final docRef = FirestoreHelper.fees.doc(
      record.id.isEmpty ? null : record.id,
    );
    await docRef.set(record.toJson()..['id'] = docRef.id);
  }

  Future<void> submitFeePaymentRequest({
    required String schoolId,
    required String studentId,
    required String feeRecordId,
    required double amount,
    required String proofImageUrl,
    String? remarks,
  }) async {
    final recordSnapshot = await FirestoreHelper.fees.doc(feeRecordId).get();
    if (!recordSnapshot.exists) throw 'Fee record not found';

    final data = recordSnapshot.data() as Map<String, dynamic>;
    final record = FeeRecordModel.fromJson(data);

    final transaction = FeeTransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      remarks: remarks ?? 'Payment submitted for review',
      proofImageUrl: proofImageUrl,
      status: TransactionStatus.processing,
    );

    final updatedRecord = record.copyWith(
      status: FeeStatus.processing,
      transactions: [...record.transactions, transaction],
      updatedAt: DateTime.now(),
    );

    await updateFeeRecord(schoolId, updatedRecord);
  }

  Future<void> syncPendingUpdates() async {
    // Firestore works online/offline automatically.
    // This is a placeholder for custom sync logic if needed.
    return;
  }

  Future<void> deleteAssignment(String schoolId, String assignmentId) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('assignments')
        .doc(assignmentId)
        .delete();

    // Also delete submissions
    final subms = await FirestoreHelper.schools
        .doc(schoolId)
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .get();

    for (var doc in subms.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> assignSubjectToStudentsInClass(
    String schoolId,
    String classNumber,
    String subjectId,
  ) async {
    final snapshot = await FirestoreHelper.schools
        .doc(schoolId)
        .collection('students')
        .where('classNumber', isEqualTo: classNumber)
        .get();

    final batch = FirestoreHelper.db.batch();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final List currentSubjects = List.from(data['assignedSubjectIds'] ?? []);
      if (!currentSubjects.contains(subjectId)) {
        currentSubjects.add(subjectId);
        batch.update(doc.reference, {'assignedSubjectIds': currentSubjects});
      }
    }
    await batch.commit();
  }

  Future<void> ensureTeacherAssignment({
    required String schoolId,
    required String teacherId,
    required String teacherName,
    required String classNumber,
    required String subjectId,
    required String subjectName,
  }) async {
    // 1. Create a deterministic ID to avoid duplicates
    final safeClass = classNumber.replaceAll(' ', '_');
    final safeSubject = subjectName.replaceAll(' ', '_');
    final assignmentDocId = '${teacherId}_${safeClass}_$safeSubject';

    // 2. Check if assignment already exists
    final existing =
        (teacherAssignments[schoolId] ?? <TeacherAssignmentModel>[])
            .firstWhereOrNull((a) => a.id == assignmentDocId);

    if (existing == null) {
      final newAssignment = TeacherAssignmentModel(
        id: assignmentDocId,
        teacherId: teacherId,
        teacherName: teacherName,
        classId: classNumber, // Using name as ID for link
        classNumber: classNumber,
        subjectId: subjectId,
        subjectName: subjectName,
        assignedAt: DateTime.now(),
      );
      await assignTeacherToSubject(schoolId, newAssignment);

      // 2. Also update Teacher profile subjectsTaught list
      final teacherDoc = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('teachers')
          .doc(teacherId)
          .get();
      if (teacherDoc.exists) {
        final List subjects = List.from(
          teacherDoc.data()?['subjectsTaught'] ?? [],
        );
        final label = '$classNumber - $subjectName';
        if (!subjects.contains(label)) {
          subjects.add(label);
          await teacherDoc.reference.update({'subjectsTaught': subjects});
        }
      }
    }
  }

  Future<void> addExamSchedule(String schoolId, ExamScheduleModel schedule) async {
    final docRef = FirestoreHelper.schools
        .doc(schoolId)
        .collection('examSchedules')
        .doc(schedule.id.isEmpty ? null : schedule.id);
    await docRef.set(schedule.toJson()..['id'] = docRef.id);
  }

  Future<void> addExamsBatch(
    String schoolId,
    List<UnifiedExamModel> exams,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var exam in exams) {
      final docRef = FirestoreHelper.schools
          .doc(schoolId)
          .collection('exams')
          .doc();
      batch.set(docRef, exam.toJson()..['id'] = docRef.id);
    }
    await batch.commit();
  }

  Future<void> deleteExamsByClass(String schoolId, String classNumber) async {
    final collection = FirestoreHelper.schools.doc(schoolId).collection('exams');
    final snapshots =
        await collection.where('classNumber', isEqualTo: classNumber).get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> deleteExam(String schoolId, String examId) async {
    await FirestoreHelper.schools
        .doc(schoolId)
        .collection('exams')
        .doc(examId)
        .delete();

    // Also delete results associated with this exam if any
    final results = await FirestoreHelper.schools
        .doc(schoolId)
        .collection('results')
        .where('examId', isEqualTo: examId)
        .get();

    for (var doc in results.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateSchoolRankingScore(String schoolId) async {
    try {
      // 1. Calculate Marks Score (Max 50)
      final allResults = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('results')
          .get();
      double marksScore = 0.0;
      if (allResults.docs.isNotEmpty) {
        double obtained = 0;
        double total = 0;
        for (var doc in allResults.docs) {
          final data = doc.data();
          obtained += (data['marksObtained'] as num? ?? 0.0).toDouble();
          total += (data['totalMarks'] as num? ?? 100.0).toDouble();
        }
        double percentage = total > 0 ? (obtained / total) * 100 : 0;
        marksScore = percentage * 0.50; // 50% weight
      }

      // 2. Calculate Faculty Score (Max 30)
      final allTeachers = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('teachers')
          .get();
      double facultyScore = 0.0;
      if (allTeachers.docs.isNotEmpty) {
        double totalDegreeScore = 0;
        for (var doc in allTeachers.docs) {
          final q = (doc.data()['qualification'] as String? ?? '')
              .toLowerCase();
          double points = 0.4; // default (BA/BSc, etc)
          if (q.contains('phd') ||
              q.contains('doctorate') ||
              q.contains('ph.d')) {
            points = 1.0;
          } else if (q.contains('ms') ||
              q.contains('mphil') ||
              q.contains('m.s') ||
              q.contains('master') ||
              q.contains('msc') ||
              q.contains('m.a')) {
            points = 0.8;
          } else if (q.contains('bs') ||
              q.contains('bachelor') ||
              q.contains('b.s') ||
              q.contains('bsc') ||
              q.contains('b.a')) {
            points = 0.6;
          }
          totalDegreeScore += points;
        }
        double avgDegreeScore =
            totalDegreeScore / allTeachers.docs.length; // 0.0 to 1.0
        facultyScore = (avgDegreeScore * 100) * 0.30; // 30% weight
      }

      // 3. Calculate Attendance Score (Max 20)
      final allAttendance = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('attendance')
          .get();
      double attendanceScore = 0.0;
      if (allAttendance.docs.isNotEmpty) {
        int presentCount = 0;
        int totalRecords = allAttendance.docs.length;
        for (var doc in allAttendance.docs) {
          final status = doc.data()['status'];
          if (status == 'present' || status == 'late' || status == 'excused') {
            presentCount++;
          }
        }
        double attendancePercentage = (presentCount / totalRecords) * 100;
        attendanceScore = attendancePercentage * 0.20; // 20% weight
      }

      // 4. Final Score & Category
      double totalScore = marksScore + facultyScore + attendanceScore;

      String category = 'Improving';
      if (totalScore >= 80) {
        category = 'Excellent';
      } else if (totalScore >= 50) {
        category = 'Good';
      }

      await FirestoreHelper.schools.doc(schoolId).update({
        'rankingScore': totalScore,
        'academicPerformanceScore': marksScore,
        'teacherQualificationScore': facultyScore,
        'attendanceScore': attendanceScore,
        'category': category,
        'lastRankingUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update ranking score: $e');
    }
  }

  Future<void> updateSchoolVisibility(String schoolId, bool isVisible) async {
    await FirestoreHelper.schools.doc(schoolId).update({
      'isVisibleOnRanking': isVisible,
    });
  }
}
