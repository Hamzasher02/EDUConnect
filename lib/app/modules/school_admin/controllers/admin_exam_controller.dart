import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../theme/app_colors.dart';

class AdminExamController extends GetxController {
  final BaseAdminController base = Get.find<BaseAdminController>();

  final examSchedulesByClass = <String, ExamScheduleModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _setupDataListeners();
  }

  void _setupDataListeners() {
    // 1. Listen to session changes to reload
    ever(base.authService.session, (_) => _bindExamSchedules());

    // 2. Initial binding
    _bindExamSchedules();
  }

  void _bindExamSchedules() {
    final schoolId = base.currentSchoolId;
    if (schoolId.isEmpty) return;

    // Listen to the stream in SchoolDataService
    final schoolSchedules = base.schoolDataService.examSchedules[schoolId];

    if (schoolSchedules != null) {
      _syncMap(schoolSchedules);
      // Also listen for changes in that specific list
      ever(schoolSchedules, (List<ExamScheduleModel> list) => _syncMap(list));
    } else {
      // If the school's list isn't initialized yet, listen to the map itself
      ever(base.schoolDataService.examSchedules, (map) {
        final list = map[schoolId];
        if (list != null) {
          _syncMap(list);
          ever(list, (List<ExamScheduleModel> l) => _syncMap(l));
        }
      });
    }
  }

  void _syncMap(List<ExamScheduleModel> list) {
    final Map<String, ExamScheduleModel> newMap = {};
    for (var schedule in list) {
      newMap[schedule.classNumber] = schedule;
    }
    examSchedulesByClass.assignAll(newMap);
    print(
      'AdminExamController: Synced ${examSchedulesByClass.length} exam schedules for school',
    );
  }

  // State for ScheduleExamView
  final selectedClass = 'None'.obs;
  final isLocked = false.obs;
  final formCount = 0.obs;
  final formSubjects = <ExamSubjectScheduleModel>[].obs;

  List<ClassModel> get classList => base.classList;

  void goToScheduleExam(String className) {
    selectedClass.value = className;
    isLocked.value = false;

    // Load existing if any
    final existing = examSchedulesByClass[className];
    if (existing != null) {
      formSubjects.assignAll(existing.subjects);
      formCount.value = existing.subjects.length;
    } else {
      // 1. Find class to get subjects
      final targetClass = base.classList.firstWhereOrNull((c) => c.name == className);
      if (targetClass != null) {
        // 2. Fetch subjects for this class using schoolDataService
        final subjects = base.schoolDataService
            .getSubjectsBySchool(base.currentSchoolId)
            .where((s) => s.classId == className)
            .toList();
        
        if (subjects.isNotEmpty) {
          formSubjects.assignAll(subjects.map((s) => ExamSubjectScheduleModel(
            id: 'EXAM_${s.name}_${DateTime.now().millisecondsSinceEpoch}',
            subjectName: s.name,
            examDate: DateTime.now().add(const Duration(days: 7)),
            examTime: const TimeOfDay(hour: 9, minute: 0),
          )).toList());
          formCount.value = subjects.length;
        } else {
          formSubjects.clear();
          formCount.value = 0;
        }
      } else {
        formSubjects.clear();
        formCount.value = 0;
      }
    }

    Get.toNamed(AppRoutes.adminScheduleExam, arguments: className);
  }

  void generateDraftSubjects(int count) {
    final List<ExamSubjectScheduleModel> drafts = List.generate(
      count,
      (index) => ExamSubjectScheduleModel(
        id: 'SUB_${index}_${DateTime.now().millisecondsSinceEpoch}',
        subjectName: 'Subject ${index + 1}',
        examDate: DateTime.now().add(Duration(days: index + 7)),
        examTime: const TimeOfDay(hour: 9, minute: 0),
      ),
    );
    formSubjects.assignAll(drafts);
  }

  Future<void> submitExamSchedule() async {
    if (base.isOffline.value) {
      Get.snackbar('Offline', 'Cannot save schedule offline.');
      return;
    }

    if (selectedClass.value == 'None' || formSubjects.isEmpty) {
      Get.snackbar('Error', 'Please configure the schedule first.');
      return;
    }

    // Check if any subject is not yet configured (e.g., date is today by default, maybe check if user changed it? 
    // Actually, usually admin sets specific dates. We'll just assume they did).

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.accentLime)),
        barrierDismissible: false,
      );

      final schoolId = base.currentSchoolId;
      final className = selectedClass.value;

      // 1. Delete existing exam records for this class (Deduplication)
      await base.schoolDataService.deleteExamsByClass(schoolId, className);

      // 2. Prepare the new schedule model
      final scheduleId =
          'SCHED_${className.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      final newSchedule = ExamScheduleModel(
        id: scheduleId,
        schoolId: schoolId,
        academicYear: '2025-2026',
        classNumber: className,
        subjects: List.from(formSubjects),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      );

      // 3. Save the main datesheet (for admin tracking)
      await base.schoolDataService.addExamSchedule(schoolId, newSchedule);

      // 4. Prepare individual exam records (UnifiedExamModel) for students/teachers
      final List<UnifiedExamModel> records = [];
      for (var sub in formSubjects) {
        records.add(
          UnifiedExamModel(
            id: '', // Will be generated in batch
            examName: 'Final Examination 2025',
            classNumber: className,
            subject: sub.subjectName,
            examDate: sub.examDate,
            startTime: '${sub.examTime.hour.toString().padLeft(2, '0')}:${sub.examTime.minute.toString().padLeft(2, '0')}',
            endTime: '${(sub.examTime.hour + 2).toString().padLeft(2, '0')}:${sub.examTime.minute.toString().padLeft(2, '0')}', // 2 hour default
            type: ExamType.term,
            teacherName: 'Assigned Faculty',
            location: 'Main Hall',
          ),
        );
      }

      // 5. Save batch
      await base.schoolDataService.addExamsBatch(schoolId, records);

      // Update local state
      examSchedulesByClass[className] = newSchedule;

      Get.back(); // Close loading
      Get.back(); // Return to list
      
      Get.snackbar(
        'Success',
        'Examination datesheet published for $className',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar('Error', 'Failed to publish datesheet: $e');
    }
  }
}
