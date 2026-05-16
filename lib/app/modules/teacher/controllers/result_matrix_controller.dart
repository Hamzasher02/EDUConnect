import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../data/models/academic_result_model.dart';
import '../../../data/models/messaging/notification_model.dart';
import '../../../data/enums/app_enums.dart';
import '../services/teacher_dashboard_service.dart';

class ResultMatrixController extends GetxController {
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();
  final _dashboardService = Get.find<TeacherDashboardService>();

  final selectedClass = ''.obs;
  final selectedSubject = ''.obs;

  final matrix = Rxn<ResultMatrixModel>();
  final isLoading = false.obs;

  // For Dropdowns
  final assignedClasses = <String>[].obs;
  final assignedSubjects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssignedData();

    // Rebuild matrix when data or selection changes
    everAll([
      _schoolDataService.students,
      _schoolDataService.exams,
      _schoolDataService.assignments,
      _schoolDataService.academicResults,
      selectedClass,
      selectedSubject,
    ], (_) => _buildMatrix());

    // Sync subjects when class changes
    ever(selectedClass, (String classNum) {
      if (classNum.isNotEmpty) {
        _updateSubjectsForClass(classNum);
      } else {
        assignedSubjects.clear();
      }
    });

    // Check for incoming arguments if any (e.g. from exam card click)
    final args = Get.arguments;
    if (args != null) {
      if (args['classId'] != null) {
        // Normalize to match what's in assignedClasses
        final rawClass = args['classId'] as String;
        final matchedClass =
            assignedClasses.firstWhereOrNull(
              (c) => _normalize(c) == _normalize(rawClass),
            ) ??
            rawClass;
        selectedClass.value = matchedClass;
      }
      if (args['subjectId'] != null) selectedSubject.value = args['subjectId'];
    }
  }

  String _normalize(String s) =>
      s.toLowerCase().replaceAll('class ', '').trim();

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
    final normalizedTarget = _normalize(classNumber);

    final Set<String> subjects = timetable
        .where((s) => _normalize(s.classNumber) == normalizedTarget)
        .map((s) => s.subjectName)
        .toSet();

    subjects.addAll(
      assigned
          .where((a) => _normalize(a.classNumber) == normalizedTarget)
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
    final normalizedCls = _normalize(classNumber);

    final Set<String> subjects = timetable
        .where((s) => _normalize(s.classNumber) == normalizedCls)
        .map((s) => s.subjectName)
        .toSet();

    subjects.addAll(
      assigned
          .where((a) => _normalize(a.classNumber) == normalizedCls)
          .map((a) => a.subjectName),
    );

    final list = subjects.toList();
    list.sort();
    return list;
  }

  void _buildMatrix() {
    final schoolId = _authService.session.value?.schoolId;
    final teacherId = _authService.session.value?.userId;

    if (schoolId == null ||
        teacherId == null ||
        selectedClass.isEmpty ||
        selectedSubject.isEmpty) {
      matrix.value = null;
      return;
    }

    // 1. Filter Students (Zero-Leakage: only for this school and class)
    final classStudents = _schoolDataService.getStudentsByClass(
      schoolId,
      selectedClass.value,
    ).where((s) => s.canStudentLogin && !s.isStruckOff).toList();

    // 2. Build Columns
    final List<ResultMatrixColumn> columns = [];

    // Tier 1: Exams
    final classExams = _schoolDataService.getExamsBySchool(schoolId);

    final targetCls = _normalize(selectedClass.value);
    final targetSub = selectedSubject.value.toLowerCase().trim();

    final filteredExams = classExams.where((e) {
      final ec = _normalize(e.classNumber);
      final es = e.subject.toLowerCase().trim();
      return ec == targetCls && es == targetSub;
    });

    for (var exam in filteredExams) {
      columns.add(
        ResultMatrixColumn(
          id: exam.id,
          name: exam.examName,
          category: exam.type == ExamType.finalExam
              ? AssessmentCategory.exam
              : AssessmentCategory.quiz,
          maxMarks: 100.0,
        ),
      );
    }

    // Tier 2: Assignments
    final classAssignments = _schoolDataService.getAssignmentsBySchool(
      schoolId,
    );
    final filteredAsns = classAssignments.where((a) {
      final ac = _normalize(a.classNumber);
      final as = a.subjectName.toLowerCase().trim();
      return ac == targetCls && as == targetSub && a.teacherId == teacherId;
    });

    for (var asn in filteredAsns) {
      columns.add(
        ResultMatrixColumn(
          id: asn.id,
          name: asn.title,
          category: AssessmentCategory.assignment,
          maxMarks: asn.maxMarks,
        ),
      );
    }

    // 3. Map Results
    final results =
        _schoolDataService.academicResults[schoolId] ?? <AcademicResultModel>[];

    final List<StudentResultRow> rows = classStudents.map((student) {
      final Map<String, AcademicResultModel> studentMap = {};

      for (var col in columns) {
        final existing = results.firstWhereOrNull(
          (r) =>
              r.studentId == student.id &&
              r.assessmentId == col.id &&
              r.subjectId == selectedSubject.value,
        );

        studentMap[col.id] =
            existing ??
            AcademicResultModel(
              id: '',
              studentId: student.id,
              studentName: student.name,
              classId: selectedClass.value,
              subjectId: selectedSubject.value,
              teacherId: teacherId,
              assessmentId: col.id,
              assessmentName: col.name,
              category: col.category,
              marksObtained: 0,
              maxMarks: col.maxMarks,
              updatedAt: DateTime.now(),
            );
      }

      return StudentResultRow(
        studentId: student.id,
        studentName: student.name,
        results: studentMap,
      );
    }).toList();

    matrix.value = ResultMatrixModel(columns: columns, rows: rows);
  }

  Future<void> updateMarks(
    String studentId,
    String assessmentId,
    double marks,
  ) async {
    final schoolId = _authService.session.value?.schoolId;
    final teacherId = _authService.session.value?.userId;
    if (schoolId == null || teacherId == null) return;

    final row = matrix.value?.rows.firstWhereOrNull(
      (r) => r.studentId == studentId,
    );
    final result = row?.results[assessmentId];
    if (result == null) return;

    if (marks > result.maxMarks) {
      Get.snackbar(
        'Error',
        'Marks cannot exceed Max Marks (${result.maxMarks})',
      );
      return;
    }

    final log = ResultAuditLog(
      teacherId: teacherId,
      timestamp: DateTime.now(),
      previousValue: result.marksObtained,
      newValue: marks,
    );

    final updated = result.copyWith(
      marksObtained: marks,
      updatedAt: DateTime.now(),
      history: [...result.history, log],
      teacherId: teacherId,
    );

    try {
      isLoading.value = true;
      await _schoolDataService.saveAcademicResult(schoolId, updated);

      // --- SEND NOTIFICATION TO STUDENT ---
      final notification = NotificationModel(
        id: '',
        title: 'Marks Updated: ${updated.subjectId}',
        message:
            'Your marks for ${updated.assessmentName} have been recorded: $marks/${updated.maxMarks}',
        timestamp: DateTime.now(),
        type: NotificationType.exam,
        audience: NotificationAudience.specificStudent,
        targetId: studentId,
        senderId: teacherId,
      );
      await _schoolDataService.addNotification(schoolId, notification);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save result: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
