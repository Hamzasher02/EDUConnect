import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../modules/student/models/result_models.dart';
import '../data/enums/app_enums.dart';
import '../data/models/submission_model.dart' as global;

class StudentResultService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
  }

  Future<List<ExamSummaryModel>> getAllExamSummaries(String studentId) async {
    _validateSession();

    final List<StudentResultModel> results = [];

    // 1. Get legacy results
    final resultsRaw = _schoolDataService.getStudentResults(studentId);
    results.addAll(
      resultsRaw.map(
        (e) => StudentResultModel(
          id: e.id,
          studentId: e.studentId,
          examName: e.examName,
          subject: e.subject,
          totalMarks: e.totalMarks,
          obtainedMarks: e.marksObtained,
          remarks: e.remarks,
          examDate: e.recordedAt,
        ),
      ),
    );

    // 2. Get Academic Results (Matrix) categorized as exams
    final academicRaw = _schoolDataService.getStudentAcademicResults(studentId);
    final examAssessments = academicRaw.where(
      (ar) =>
          ar.category == AssessmentCategory.exam ||
          ar.category == AssessmentCategory.quiz,
    );

    for (var ar in examAssessments) {
      // Deduplicate: If an exam with same name and subject already exists in results, skip
      final isDuplicate = results.any(
        (r) =>
            r.examName.toLowerCase().trim() ==
                ar.assessmentName.toLowerCase().trim() &&
            r.subject.toLowerCase().trim() == ar.subjectId.toLowerCase().trim(),
      );

      if (isDuplicate) continue;

      results.add(
        StudentResultModel(
          id: ar.id,
          studentId: ar.studentId,
          examName: ar.assessmentName,
          subject: ar.subjectId.ifEmpty('General'),
          totalMarks: ar.maxMarks,
          obtainedMarks: ar.marksObtained,
          remarks: '',
          examDate: ar.updatedAt,
        ),
      );
    }

    // Group results by examName
    final Map<String, List<StudentResultModel>> grouped = {};
    for (var res in results) {
      if (!grouped.containsKey(res.examName)) {
        grouped[res.examName] = [];
      }
      grouped[res.examName]!.add(res);
    }

    final List<ExamSummaryModel> summaries = [];
    final studentDoc = _schoolDataService.getStudentProfile(studentId);
    final classId = studentDoc?['classNumber'] ?? '';

    for (var entry in grouped.entries) {
      final examName = entry.key;
      final subjectResults = entry.value;

      double totalObtained = 0;
      double totalPossible = 0;
      for (var res in subjectResults) {
        totalObtained += res.obtainedMarks;
        totalPossible += res.totalMarks;
      }

      // Calculate rank
      int? rank;
      int? totalInClass;
      if (classId.isNotEmpty) {
        final ranking = await getRankInClass(
          studentId: studentId,
          classId: classId,
          examName: examName,
        );
        rank = ranking['rank'];
        totalInClass = ranking['totalStudents'];
      }

      summaries.add(
        ExamSummaryModel(
          examName: examName,
          totalObtained: totalObtained,
          totalPossible: totalPossible,
          subjectResults: subjectResults,
          examDate: subjectResults.first.examDate,
          rank: rank,
          totalStudents: totalInClass,
        ),
      );
    }

    // Sort by date latest first
    summaries.sort((a, b) => b.examDate.compareTo(a.examDate));

    return summaries;
  }

  Future<List<Map<String, dynamic>>> getContinuousAssessment(
    String studentId,
  ) async {
    _validateSession();
    final schoolId = _authService.session.value?.schoolId ?? '';

    final List<Map<String, dynamic>> items = [];

    // 1. Get Graded Submissions (Assignments graded via Assignment View)
    final allSubmissions = _schoolDataService.getStudentSubmissions(studentId);
    final gradedAssignments = allSubmissions
        .where((s) => s.status == global.SubmissionStatus.graded)
        .toList();

    // 2. Get Academic Results (Marks added via Matrix/Continuous Assessment)
    final academicResults = _schoolDataService.getStudentAcademicResults(
      studentId,
    );

    // 3. Get Exam Results (Legacy/Direct results collection)
    final examResults = _schoolDataService.getStudentResults(studentId);

    // Helper to resolve assignment details
    final allAssignments = _schoolDataService.getAssignmentsBySchool(schoolId);

    // Track keys to avoid duplicates (Subject + Title + Type)
    final Set<String> processedKeys = {};

    String generateKey(String subject, String title, String type) {
      return '${subject.toLowerCase().trim()}_${title.toLowerCase().trim()}_${type.toLowerCase().trim()}';
    }

    // Process Academic Results first (Matrix-based: most authoritative)
    for (var ar in academicResults) {
      if (ar.marksObtained <= 0 && ar.history.isEmpty) continue;

      final type = ar.category == AssessmentCategory.assignment
          ? 'Assignment'
          : 'Exam';
      final key = generateKey(ar.subjectId, ar.assessmentName, type);

      // Also track the physical assessment ID if it exists
      if (ar.assessmentId.isNotEmpty) processedKeys.add(ar.assessmentId);

      processedKeys.add(key);
      items.add({
        'type': type,
        'title': ar.assessmentName,
        'subject': ar.subjectId.ifEmpty('General'),
        'obtained': ar.marksObtained,
        'total': ar.maxMarks,
        'date': ar.updatedAt,
        'feedback': '',
      });
    }

    // Process Assignments from submissions
    for (var a in gradedAssignments) {
      final asn = allAssignments.firstWhereOrNull(
        (asgn) => asgn.id == a.assignmentId,
      );
      final title = asn?.title ?? 'Assignment';
      final subject = asn?.subjectName ?? a.subjectId.ifEmpty('General');
      final key = generateKey(subject, title, 'Assignment');

      if (processedKeys.contains(a.assignmentId) ||
          processedKeys.contains(key)) {
        continue;
      }

      processedKeys.add(key);
      processedKeys.add(a.assignmentId);

      items.add({
        'type': 'Assignment',
        'title': title,
        'subject': subject,
        'obtained': a.marksObtained ?? 0,
        'total': a.maxMarks.toDouble(),
        'date': a.submittedAt,
        'feedback': a.feedback,
      });
    }

    // Process Exam Results (Direct/Legacy collection)
    for (var r in examResults) {
      final key = generateKey(r.subject, r.examName, 'Exam');

      if (processedKeys.contains(key)) continue;

      processedKeys.add(key);
      items.add({
        'type': 'Exam',
        'title': r.examName,
        'subject': r.subject.ifEmpty('General'),
        'obtained': r.marksObtained,
        'total': r.totalMarks,
        'date': r.recordedAt,
        'feedback': r.remarks,
      });
    }

    // Grouping logic remains the same
    final Map<String, List<Map<String, dynamic>>> subjectWise = {};
    for (var item in items) {
      String sub = item['subject'] as String;
      if (sub.isEmpty) sub = 'General';

      if (!subjectWise.containsKey(sub)) {
        subjectWise[sub] = [];
      }
      subjectWise[sub]!.add(item);
    }

    final List<Map<String, dynamic>> result = [];
    subjectWise.forEach((subject, subjectItems) {
      double subTotalObtained = 0;
      double subTotalPossible = 0;

      for (var i in subjectItems) {
        subTotalObtained += i['obtained'];
        subTotalPossible += i['total'];
      }

      result.add({
        'subject': subject,
        'totalObtained': subTotalObtained,
        'totalPossible': subTotalPossible,
        'items': subjectItems
          ..sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
          ),
      });
    });

    return result;
  }

  Future<Map<String, dynamic>> getRankInClass({
    required String studentId,
    required String classId,
    required String examName,
  }) async {
    final session = _authService.session.value;
    if (session == null) throw 'Unauthorized';
    final schoolId = session.schoolId ?? '';

    // 1. Get all active students in the class
    final allStudents = _schoolDataService
        .getStudentsForClass(schoolId, classId)
        .where((s) => s.canStudentLogin && !s.isStruckOff)
        .toList();

    if (allStudents.isEmpty) return {'rank': -1, 'totalStudents': 0};

    // 2. Calculate total marks for each student for this specific exam
    final List<_StudentScore> scores = [];

    for (var student in allStudents) {
      double totalObtained = 0;

      // Combine legacy results
      final legacy = _schoolDataService
          .getResultsBySchool(schoolId)
          .where((r) => r.studentId == student.id && r.examName == examName);
      for (var r in legacy) {
        totalObtained += r.marksObtained;
      }

      // Combine academic results (Matrix)
      final academic = _schoolDataService
          .getStudentAcademicResults(student.id)
          .where(
            (ar) =>
                ar.assessmentName == examName &&
                (ar.category == AssessmentCategory.exam ||
                    ar.category == AssessmentCategory.quiz),
          );

      for (var ar in academic) {
        // Deduplicate logic similar to getAllExamSummaries
        final isAlreadyAdded = legacy.any(
          (r) =>
              r.subject.toLowerCase().trim() == ar.subjectId.toLowerCase().trim(),
        );
        if (!isAlreadyAdded) {
          totalObtained += ar.marksObtained;
        }
      }

      scores.add(_StudentScore(studentId: student.id, score: totalObtained));
    }

    // 3. Sort by score descending
    scores.sort((a, b) => b.score.compareTo(a.score));

    // 4. Find rank
    int rank = -1;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i].studentId == studentId) {
        rank = i + 1;
        break;
      }
    }

    return {
      'rank': rank,
      'totalStudents': scores.length,
      'topScore': scores.isNotEmpty ? scores.first.score : 0.0,
    };
  }
}

class _StudentScore {
  final String studentId;
  final double score;
  _StudentScore({required this.studentId, required this.score});
}

extension StringExtension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
