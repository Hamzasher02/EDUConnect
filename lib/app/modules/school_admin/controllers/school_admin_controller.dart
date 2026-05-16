import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import 'package:get/get.dart';
import 'admin_announcement_controller.dart';
import 'admin_report_controller.dart';
import 'admin_student_controller.dart';
import '../../../theme/app_colors.dart';
import '../models/school_admin_models.dart';
import 'base_admin_controller.dart';
import 'admin_fee_controller.dart';
import 'admin_exam_controller.dart';
import 'admin_teacher_controller.dart';
import 'admin_timetable_controller.dart';
import '../../../routes/app_routes.dart';
import '../views/teacher_detail_view.dart'; // Added for refresh navigation

/// Facade for School Admin Panel to bridge monolithic logic to granular controllers.
class SchoolAdminController extends GetxController {
  final base = Get.find<BaseAdminController>();
  final student = Get.find<AdminStudentController>();
  final fee = Get.find<AdminFeeController>();
  final exam = Get.find<AdminExamController>();
  final announcement = Get.find<AdminAnnouncementController>();
  final report = Get.find<AdminReportController>();
  final teacher = Get.find<AdminTeacherController>();
  final timetable = Get.find<AdminTimetableController>();

  // Delegate essential base props for easier access in UI
  RxString get schoolName => base.schoolName;
  RxBool get isOffline => base.isOffline;
  void toggleOffline() => base.toggleOffline();

  // Student Delegates
  RxString get studentSearchQuery => student.studentSearchQuery;
  void setSearchQuery(String query) => student.studentSearchQuery.value = query;
  List<StudentModel> get filteredStudentsForSelectedClass =>
      student.filteredStudentsForSelectedClass;
  void toggleStruckOff(StudentModel s) => student.toggleStruckOff(s);

  // Archive & Queue Delegates
  RxInt get archiveQueueTab => student.archiveQueueTab;
  List<StudentModel> get inactiveQueueStudents => student.archiveQueueStudents;
  List<StudentModel> get archivedStudentsList => student.archivedStudentsList;
  Map<String, StudentSummaryReportModel> get studentSummaryReports =>
      student.studentSummaryReports;

  void archiveStudentNow(String id) => student.archiveStudentNow(id);
  void checkAndAutoDeleteEligibleArchived() =>
      student.checkAndAutoDeleteEligibleArchived();
  void generateStudentSummaryReport(StudentModel s) =>
      student.generateStudentSummaryReport(s);

  // Navigation Delegates
  void goToRegisterStudent() => Get.toNamed(AppRoutes.adminRegisterStudent);
  void goToManageFee() => Get.toNamed(AppRoutes.adminManageFee);

  bool guardSelectedClass() => base.guardSelectedClass();

  RxString get selectedClass => base.selectedClass;

  // Registration Form Keys
  final studentFormKey = GlobalKey<FormState>();
  final teacherFormKey = GlobalKey<FormState>();

  // Placeholder for missing regs in facade
  final regStudentNameController = TextEditingController();
  final regStudentEmailController =
      TextEditingController(); // New: Manual email entry
  final regRollNoController = TextEditingController();
  final regPasswordController =
      TextEditingController(); // Added password controller
  final regParentEmailController = TextEditingController();
  final regParentCnicController = TextEditingController();
  final regContactNumberController = TextEditingController();
  final regHomeAddressController = TextEditingController();
  final regMonthlyFeeController = TextEditingController();

  // Photo Logic (Disabled)

  void registerStudent() async {
    if (!(studentFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final studentName = regStudentNameController.text.trim();
    final studentEmail = regStudentEmailController.text.trim();
    final studentRoll = regRollNoController.text.trim();
    final password = regPasswordController.text.trim();
    final parentEmail = regParentEmailController.text.trim();
    final parentCnic = regParentCnicController.text.trim();
    final contactNumber = regContactNumberController.text.trim();
    final address = regHomeAddressController.text.trim();

    if (studentName.isEmpty ||
        studentEmail.isEmpty ||
        studentRoll.isEmpty ||
        password.isEmpty ||
        parentEmail.isEmpty ||
        parentCnic.isEmpty ||
        contactNumber.isEmpty ||
        address.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      final emailLower = studentEmail.toLowerCase();
      final roll = studentRoll.trim();

      // Check for duplicate email in Global Registry
      final emailExists = await base.authService.checkEmailExists(emailLower);
      if (emailExists) {
        Get.snackbar('Duplicate Error', 'A user with this email ($studentEmail) is already registered.');
        return;
      }

      // Check for duplicate Roll No in the same school
      final studentList = base.schoolDataService.getStudentsBySchool(base.currentSchoolId);
      final rollExists = studentList.any((s) => s.rollNo == roll);
      if (rollExists) {
        Get.snackbar('Duplicate Error', 'Roll No $roll already exists in this school.');
        return;
      }

      await Get.showOverlay(
        asyncFunction: () async {
          final schoolId = base.currentSchoolId;
          String? photoUrl;

          final newStudent = StudentModel(
            id: '',
            schoolId: schoolId,
            name: regStudentNameController.text.trim(),
            rollNo: studentRoll,
            classNumber: selectedClass.value,
            photoUrl: photoUrl,
            email: studentEmail.toLowerCase(),
            password: regPasswordController.text.trim(),
            isPasswordCreated: true,
            parentEmail: regParentEmailController.text.trim(),
            parentCnic: regParentCnicController.text.trim(),
            contactNumber: regContactNumberController.text.trim(),
            address: regHomeAddressController.text.trim(),
            createdAt: DateTime.now(),
            admissionDate: DateTime.now(),
          );

          final studentId = await base.schoolDataService.addStudent(
            base.currentSchoolId,
            newStudent,
          );

          // Sync to Registry
          await base.authService.syncUserRegistry(
            uid: studentId,
            email: newStudent.email!,
            role: UserRole.student,
            schoolId: base.currentSchoolId,
            name: newStudent.name,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .update({'password': newStudent.password});

          // Clear forms
          _clearStudentForm();

          Get.back(); // Go back from register screen
          Get.snackbar(
            'Success',
            'Student registered successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        },
        loadingWidget: _buildLoadingOverlay('Registering Student...'),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _clearStudentForm() {
    regStudentNameController.clear();
    regStudentEmailController.clear();
    regRollNoController.clear();
    regPasswordController.clear();
    regParentEmailController.clear();
    regParentCnicController.clear();
    regContactNumberController.clear();
    regHomeAddressController.clear();
  }

  // Teacher Delegates
  void goToRegisterTeacher() => Get.toNamed(AppRoutes.adminRegisterTeacher);
  void goToEnrolledTeachers() => Get.toNamed(AppRoutes.adminEnrolledTeachers);

  final regTeacherNameController = TextEditingController();
  final regTeacherEmailController = TextEditingController();
  final regTeacherContactController = TextEditingController();
  final regTeacherQualificationController = TextEditingController();
  final regTeacherExperienceController = TextEditingController();
  final regTeacherSpecializationController = TextEditingController();
  final regTeacherPasswordController = TextEditingController();

  // Teacher Photo Logic (Disabled)

  void registerTeacher() async {
    if (!(teacherFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = regTeacherNameController.text.trim();
    final email = regTeacherEmailController.text.trim();
    final password = regTeacherPasswordController.text.trim();
    final contact = regTeacherContactController.text.trim();
    final qualification = regTeacherQualificationController.text.trim();
    final experience = regTeacherExperienceController.text.trim();
    final specialization = regTeacherSpecializationController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        contact.isEmpty ||
        qualification.isEmpty ||
        experience.isEmpty ||
        specialization.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }


    try {
      final emailLower = email.toLowerCase();
      // Check for duplicate email
      final emailExists = await base.authService.checkEmailExists(emailLower);
      if (emailExists) {
        Get.snackbar('Duplicate Error', 'A user with this email ($email) is already registered.');
        return;
      }

      await Get.showOverlay(
        asyncFunction: () async {
          final schoolId = base.currentSchoolId;
          String? photoUrl;

          final newTeacher = TeacherModel(
            id: '',
            schoolId: schoolId,
            name: name,
            email: email.trim().toLowerCase(),
            password: password,
            contactNumber: contact,
            qualification: qualification,
            experienceYears: int.tryParse(experience) ?? 0,
            subjectSpecialization: specialization,
            profilePhotoUrl: photoUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            isPasswordCreated: true,
          );

          final teacherId = await base.schoolDataService.addTeacher(
            schoolId,
            newTeacher,
          );

          // Standardize Registry Sync
          await base.authService.syncUserRegistry(
            uid: teacherId,
            email: newTeacher.email,
            role: UserRole.teacher,
            schoolId: schoolId,
            name: newTeacher.name,
            password: password,
          );

          _clearTeacherForm();

          Get.back(); // Go back from register screen
          Get.snackbar(
            'Success',
            'Teacher registered successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        },
        loadingWidget: _buildLoadingOverlay('Adding Faculty Member...'),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildLoadingOverlay(String message) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accentLime),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearTeacherForm() {
    regTeacherNameController.clear();
    regTeacherEmailController.clear();
    regTeacherPasswordController.clear();
    regTeacherContactController.clear();
    regTeacherQualificationController.clear();
    regTeacherExperienceController.clear();
    regTeacherSpecializationController.clear();
  }

  List<TeacherModel> get teachers => teacher.teachers;
  void removeTeacher(String id) => teacher.removeTeacher(id);

  void goToTeacherDetail(String id) =>
      Get.toNamed(AppRoutes.adminTeacherDetail, arguments: id);

  void openTeacherTimetable(String id) =>
      Get.toNamed(AppRoutes.adminTeacherTimetable, arguments: id);

  // Timetable Delegates
  RxString get selectedTimetableClass => timetable.selectedTimetableClass;
  RxString get timetableSelectedDay => timetable.timetableSelectedDay;
  List<ClassTimetableSlotModel> get currentDaySlots =>
      timetable.currentDaySlots;
  void goToClassTimetable(String cls) => timetable.goToClassTimetable(cls);
  void saveTimetableChanges() => timetable.saveTimetableChanges();
  void removeTimetableSlot(String id) => timetable.removeTimetableSlot(id);
  void addTimetableSlot({
    required String subjectId,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required String start,
    required String end,
    required String room,
  }) => timetable.addTimetableSlot(
    subjectId: subjectId,
    subjectName: subjectName,
    teacherId: teacherId,
    teacherName: teacherName,
    start: start,
    end: end,
    room: room,
  );

  void updateTimetableSlot({
    required String slotId,
    required String subjectId,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required String start,
    required String end,
    required String room,
    required String classNumber,
    required String day,
  }) => timetable.updateTimetableSlot(
    slotId: slotId,
    subjectId: subjectId,
    subjectName: subjectName,
    teacherId: teacherId,
    teacherName: teacherName,
    start: start,
    end: end,
    room: room,
    classNumber: classNumber,
    day: day,
  );

  RxString get selectedTeacherId => teacher.selectedTeacherId;
  RxString get timetableDay => timetable.timetableSelectedDay;
  RxString get timetableClass => timetable.selectedTimetableClass;
  RxString get timetableSubject => timetable.timetableSubject;
  RxString get timetableRoom => timetable.timetableRoom;
  Map<String, List<ClassTimetableSlotModel>> get teacherAssignments =>
      timetable.teacherAssignments;
  void removeAssignedClass(String teacherId, String slotId) =>
      timetable.removeAssignedClass(teacherId, slotId);

  Future<void> removeFormalAssignment(String assignmentId) async {
    try {
      await base.schoolDataService.deleteTeacherAssignment(
        base.currentSchoolId,
        assignmentId,
      );
      Get.snackbar('Success', 'Formal assignment removed');
      // Refresh current view if needed
      final teacherId = Get.arguments?.toString();
      if (teacherId != null) {
        Get.off(
          () => const TeacherDetailView(),
          arguments: teacherId,
          preventDuplicates: false,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove assignment: $e');
    }
  }

  // Fee Delegates
  void openStudentFeeDetails(String id) {
    student.selectedStudent.value = student.allStudents.firstWhereOrNull(
      (s) => s.id == id,
    );
    fee.openStudentFeeDetails(id);
  }

  double computeTotalDues(String id) => fee.computeTotalDues(id);
  Rxn<StudentModel> get selectedStudent => student.selectedStudent;
  List<MonthlyFeeRecordModel> getTotalFeeRecords(String studentId) =>
      fee.feeRecordsByStudent[studentId] ?? <MonthlyFeeRecordModel>[];
  Map<String, List<MonthlyFeeRecordModel>> get feeRecordsByStudent =>
      fee.feeRecordsByStudent;

  void submitFeePayment(String studentId, double amount, String month) =>
      fee.submitFeePayment(studentId, amount, month);
  Map<String, RxList<StudentModel>> get studentsByClass =>
      student.studentsByClass;

  // Exam Delegates
  List<ClassModel> get classList => exam.classList;
  Map<String, ExamScheduleModel> get examSchedulesByClass =>
      exam.examSchedulesByClass;
  void goToScheduleExam(String cls) => exam.goToScheduleExam(cls);

  // Announcement / Notification Delegates
  Rx<NotificationType> get notifType => announcement.notifType;
  Rx<NotificationAudience> get notifAudience => announcement.notifAudience;
  RxString get notifTargetClass => announcement.notifTargetClass;
  RxString get notifTargetStudentId => announcement.notifTargetStudentId;
  RxString get notifTargetTeacherId => announcement.notifTargetTeacherId;
  RxString get notifTitle => announcement.notifTitle;
  RxString get notifMessage => announcement.notifMessage;

  RxString get notificationSearchQuery => announcement.searchQuery;
  List<NotificationModel> get notificationsForSchool =>
      announcement.notificationsForSchool;
  List<NotificationModel> get filteredNotifications =>
      announcement.notificationsForSchool;
  Rxn<NotificationModel> get selectedNotification =>
      announcement.selectedNotification;
  Rxn<NotificationModel> get selectedAdminNotification =>
      announcement.selectedNotification;

  void updateNotificationSearchQuery(String q) =>
      announcement.updateSearchQuery(q);
  void sendNotification() => announcement.sendNotification();
  void openNotification(NotificationModel n) =>
      announcement.openNotification(n);
  void openCreateNotification() => announcement.openCreateNotification();
  void openSentNotifications() => announcement.openSentNotifications();
  void markAllNotificationsAsRead() => announcement.markAllAsRead();

  // Report Delegates
  RxString get reportSearchQuery => report.reportSearchQuery;
  RxString get reportSelectedClass => report.reportSelectedClass;
  Rx<ReportStatusFilter> get reportStatusFilter => report.reportStatusFilter;
  RxList<StudentModel> get reportResults => report.reportResults;
  void generateReport() => report.generateReport();
  void downloadPdf() => report.downloadPdf();
  void downloadExcel() => report.downloadExcel();
  void goToArchivedStudents() => report.goToArchivedStudents();
  void goToArchivedTeachers() => report.goToArchivedTeachers();

  // Invitations & Security
  final invitations = <InvitationModel>[].obs;
  void markInviteUsed(String id, String password) {
    final invite = invitations.firstWhereOrNull((i) => i.token == id);
    if (invite != null) {
      invite.isUsed = true;
      Get.snackbar('Success', 'Password created successfully');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // Archives
  List<StudentModel> get archivedStudents => student.archivedStudentsList;
  List<TeacherModel> get archivedTeachers => teacher.archivedTeachers;

  void openArchiveReportDetail({required bool isStudent, required String id}) =>
      report.openArchiveReportDetail(isStudent: isStudent, id: id);

  Map<String, StudentArchiveReportModel> get studentArchiveReportsByStudentId =>
      report.studentReports;
  Map<String, TeacherArchiveReportModel> get teacherArchiveReportsByTeacherId =>
      report.teacherReports;

  // Class Management
  final createClassName = ''.obs;
  final createClassDescription = ''.obs;
  final draftSubjects = <String>[].obs;
  final subjectInputController = TextEditingController();

  void addDraftSubject() {
    final name = subjectInputController.text.trim();
    if (name.isNotEmpty && !draftSubjects.contains(name)) {
      draftSubjects.add(name);
      subjectInputController.clear();
    }
  }

  void removeDraftSubject(int index) {
    draftSubjects.removeAt(index);
  }

  void createNewClass() async {
    if (createClassName.value.trim().isEmpty) {
      Get.snackbar('Error', 'Class name is required');
      return;
    }

    final className = createClassName.value.trim();

    // Uniqueness check
    final classes = base.schoolDataService.classes[base.currentSchoolId] ?? [];
    if (classes.any(
      (c) => c.name.toLowerCase() == className.toLowerCase(),
    )) {
      Get.snackbar(
        'Error',
        'Class with name "$className" already exists',
      );
      return;
    }

    try {
      final newClass = ClassModel(
        id: '',
        name: className,
        description: createClassDescription.value,
        createdAt: DateTime.now(),
      );

      await base.schoolDataService.addClass(base.currentSchoolId, newClass);

      // Create draft subjects if any
      final subjectsToCreate = List<String>.from(draftSubjects);
      for (var subjectName in subjectsToCreate) {
        final subUnit = SubjectModel(
          id: '',
          classId: className, // Using class name as link per existing pattern
          name: subjectName,
          createdAt: DateTime.now(),
        );
        await base.schoolDataService.addSubject(base.currentSchoolId, subUnit);
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Class $className created with ${subjectsToCreate.length} subjects',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      createClassName.value = '';
      createClassDescription.value = '';
      draftSubjects.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create class: $e');
    }
  }

  // --- Predefined Class Logic ---
  final Map<String, Map<String, dynamic>> predefinedClasses = {
    'KG': {
      'desc': 'Kindergarten - Early Stage Education',
      'subjects': ['English', 'Urdu', 'Math', 'General Knowledge', 'Art', 'Rhymes'],
    },
    'Class 1': {
      'desc': 'Primary Education - Grade 1',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'Social Studies', 'Computer'],
    },
    'Class 2': {
      'desc': 'Primary Education - Grade 2',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'Social Studies', 'Computer'],
    },
    'Class 3': {
      'desc': 'Primary Education - Grade 3',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'Social Studies', 'Computer'],
    },
    'Class 4': {
      'desc': 'Primary Education - Grade 4',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'Social Studies', 'Computer'],
    },
    'Class 5': {
      'desc': 'Primary Education - Grade 5',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'Social Studies', 'Computer'],
    },
    'Class 6': {
      'desc': 'Middle School - Grade 6',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'History', 'Geography', 'Computer'],
    },
    'Class 7': {
      'desc': 'Middle School - Grade 7',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'History', 'Geography', 'Computer'],
    },
    'Class 8': {
      'desc': 'Middle School - Grade 8',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Science', 'History', 'Geography', 'Computer'],
    },
    'Class 9': {
      'desc': 'Secondary Education - Grade 9',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Physics', 'Chemistry', 'Biology', 'Computer Science', 'Pakistan Studies'],
    },
    'Class 10': {
      'desc': 'Secondary Education - Grade 10',
      'subjects': ['English', 'Urdu', 'Math', 'Islamiat', 'Physics', 'Chemistry', 'Biology', 'Computer Science', 'Pakistan Studies'],
    },
    'Class 11': {
      'desc': 'Higher Secondary - Year 1',
      'subjects': ['English', 'Urdu', 'Physics', 'Chemistry', 'Biology', 'Mathematics', 'Pakistan Studies', 'Islamiat'],
    },
    'Class 12': {
      'desc': 'Higher Secondary - Year 2',
      'subjects': ['English', 'Urdu', 'Physics', 'Chemistry', 'Biology', 'Mathematics', 'Pakistan Studies', 'Islamiat'],
    },
  };

  void onClassSelected(String className) {
    if (predefinedClasses.containsKey(className)) {
      final config = predefinedClasses[className]!;
      createClassName.value = className;
      createClassDescription.value = config['desc'];
      draftSubjects.assignAll(List<String>.from(config['subjects']));
    } else {
      createClassName.value = className;
      createClassDescription.value = '';
      draftSubjects.clear();
    }
  }

  void renameClass(String classId, String oldName, String newName) async {
    if (newName.isEmpty || oldName == newName) return;

    try {
      final updatedClass = ClassModel(
        id: classId,
        name: newName,
        description: '', // Keep old or update if needed
        createdAt: DateTime.now(),
      );

      await base.schoolDataService.updateClass(
        base.currentSchoolId,
        classId, // Use classId instead of oldName for more precise matching
        updatedClass,
      );

      // Also update selectedClass if it was the one renamed
      if (base.selectedClass.value == oldName) {
        base.selectedClass.value = newName;
      }

      Get.snackbar('Success', 'Class renamed to $newName');
    } catch (e) {
      Get.snackbar('Error', 'Failed to rename class: $e');
    }
  }

  // Exam Scheduling
  RxString get selectedExamClass => exam.selectedClass;
  bool get isExamScheduleLocked => exam.isLocked.value;
  RxInt get examScheduleFormCount => exam.formCount;
  RxList<ExamSubjectScheduleModel> get examScheduleFormSubjects =>
      exam.formSubjects;
  void generateDraftSubjects(int count) => exam.generateDraftSubjects(count);
  void submitExamSchedule() => exam.submitExamSchedule();

  // Attendance & Assignment Management
  final subjectName = ''.obs;
  final subjectDescription = ''.obs;
  final assignmentTeacherId = ''.obs;
  final assignmentTeacherName = ''.obs;
  final assignmentClassId = ''.obs;
  final assignmentClassNumber = ''.obs;
  final assignmentSubjectId = ''.obs;
  final assignmentSubjectName = ''.obs;

  void showTeacherAssignmentDialog(TeacherModel teacher) {
    assignmentTeacherId.value = teacher.id;
    assignmentTeacherName.value = teacher.name;
    assignmentClassId.value = '';
    assignmentClassNumber.value = '';
    assignmentSubjectId.value = '';
    assignmentSubjectName.value = '';

    Get.dialog(
      Theme(
        data: ThemeData.dark(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accentLime.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assign Class & Subject',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faculty: ${teacher.name}',
                  style: TextStyle(
                    color: AppColors.accentLime.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Class Dropdown
                const Text(
                  'Select Class',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final classes = classList;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: assignmentClassId.value.isEmpty
                            ? null
                            : assignmentClassId.value,
                        hint: const Text(
                          'Select Class',
                          style: TextStyle(color: Colors.white30),
                        ),
                        isExpanded: true,
                        dropdownColor: AppColors.cardDark,
                        items: classes.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          assignmentClassId.value = v ?? '';
                          final cls = classes.firstWhere((c) => c.id == v);
                          assignmentClassNumber.value = cls.name;
                          assignmentSubjectId.value = '';
                          assignmentSubjectName.value = '';
                        },
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Subject Dropdown
                const Text(
                  'Select Subject',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final subjectsList = getSubjectsForClass(
                    assignmentClassNumber.value,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: assignmentSubjectId.value.isEmpty
                            ? null
                            : assignmentSubjectId.value,
                        hint: Text(
                          assignmentClassId.value.isEmpty
                              ? 'Select Class First'
                              : 'Select Subject',
                          style: const TextStyle(color: Colors.white30),
                        ),
                        isExpanded: true,
                        dropdownColor: AppColors.cardDark,
                        items: subjectsList.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              s.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: assignmentClassId.value.isEmpty
                            ? null
                            : (v) {
                                assignmentSubjectId.value = v ?? '';
                                final sub = subjectsList.firstWhere(
                                  (s) => s.id == v,
                                );
                                assignmentSubjectName.value = sub.name;
                              },
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (assignmentClassId.value.isNotEmpty &&
                            assignmentSubjectId.value.isNotEmpty) {
                          assignTeacherToSubject(
                            assignmentClassId.value,
                            assignmentClassNumber.value,
                          );
                          Get.back();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select class and subject',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Assign'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SubjectModel> getSubjectsForClass(String className) {
    if (className.isEmpty) return [];
    return base.schoolDataService
        .getSubjectsBySchool(base.currentSchoolId)
        .where((s) => s.classId == className)
        .toList();
  }

  void showCreateSubjectDialog(String classId) {
    subjectName.value = '';
    subjectDescription.value = '';

    Get.dialog(
      Theme(
        data: ThemeData.dark(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accentLime.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Subject',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Class: $classId',
                  style: TextStyle(
                    color: AppColors.accentLime.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: (v) => subjectName.value = v,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accentLime),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => subjectDescription.value = v,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accentLime),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        createSubject(classId);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLime,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createSubject(String classId) async {
    if (subjectName.value.isEmpty) {
      Get.snackbar('Error', 'Subject name is required');
      return;
    }

    try {
      final newSubject = SubjectModel(
        id: '',
        classId: classId,
        name: subjectName.value,
        description: subjectDescription.value,
        createdAt: DateTime.now(),
      );

      await base.schoolDataService.addSubject(base.currentSchoolId, newSubject);
      Get.snackbar('Success', 'Subject ${subjectName.value} created');
      subjectName.value = '';
      subjectDescription.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to create subject: $e');
    }
  }

  void assignTeacherToSubject(String classId, String classNumber) async {
    if (assignmentTeacherId.value.isEmpty ||
        assignmentSubjectId.value.isEmpty) {
      Get.snackbar('Error', 'Please select both Teacher and Subject');
      return;
    }

    try {
      final assignment = TeacherAssignmentModel(
        id: '',
        teacherId: assignmentTeacherId.value,
        teacherName: assignmentTeacherName.value,
        classId: classId,
        classNumber: classNumber,
        subjectId: assignmentSubjectId.value,
        subjectName: assignmentSubjectName.value,
        assignedAt: DateTime.now(),
      );

      await base.schoolDataService.assignTeacherToSubject(
        base.currentSchoolId,
        assignment,
      );
      Get.snackbar('Success', 'Teacher assigned successfully');
      assignmentTeacherId.value = '';
      assignmentSubjectId.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign teacher: $e');
    }
  }

  void deleteTeacherAssignment(String id) async {
    try {
      await base.schoolDataService.deleteTeacherAssignment(
        base.currentSchoolId,
        id,
      );
      Get.snackbar('Success', 'Assignment removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove assignment: $e');
    }
  }

  // --- NEW: PERFORMANCE AGGREGATION ---

  double getSubjectAttendance(String studentId, String subjectId) {
    final schoolId = base.currentSchoolId;
    final records = base.schoolDataService.subjectAttendance[schoolId]
            ?.where((r) => r.studentId == studentId && r.subjectId == subjectId)
            .toList() ??
        [];

    if (records.isEmpty) return 0.0;
    final present = records
        .where((r) => r.status.name == 'present')
        .length;
    return present / records.length;
  }

  double getSubjectMarks(String studentId, String subjectId) {
    final schoolId = base.currentSchoolId;
    final results = base.schoolDataService.academicResults[schoolId]
            ?.where((r) => r.studentId == studentId && r.subjectId == subjectId)
            .toList() ??
        [];

    if (results.isEmpty) return 0.0;
    double totalObtained = 0;
    double totalMax = 0;
    for (var r in results) {
      totalObtained += r.marksObtained;
      totalMax += r.maxMarks;
    }
    return totalMax > 0 ? (totalObtained / totalMax) * 100 : 0.0;
  }
}
