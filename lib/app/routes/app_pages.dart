import 'package:get/get.dart';

import '../modules/school_admin/views/create_class_view.dart';
import '../modules/school_admin/views/manage_subjects_view.dart';
import '../modules/school_admin/views/teacher_assignment_view.dart';
import '../modules/school_admin/views/subject_performance_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/restricted_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/school/bindings/school_binding.dart';
import '../modules/school/views/register_school_view.dart';
import '../modules/school/views/school_detail_view.dart';
import '../modules/system/bindings/system_binding.dart';
import '../modules/system/views/backup_view.dart';
import '../modules/system/views/restore_view.dart';
import '../modules/message/bindings/message_binding.dart';
import '../modules/message/views/message_view.dart';
import '../modules/system/views/audit_log_view.dart';
import '../modules/system/views/profile_view.dart';
import '../modules/school_admin/bindings/school_admin_binding.dart';
import '../modules/school_admin/views/admin_dashboard_view.dart';
import '../modules/school_admin/views/manage_students_by_class_view.dart';
import '../modules/school_admin/views/manage_teachers_view.dart';
import '../modules/school_admin/views/manage_exams_view.dart';
import '../modules/school_admin/views/reports_hub_view.dart';
import '../modules/school_admin/views/class_timetable_hub_view.dart';
import '../modules/school_admin/views/view_enrolled_students_view.dart';
import '../modules/school_admin/views/register_student_view.dart';
import '../modules/school_admin/views/create_password_view.dart';
import '../modules/school_admin/views/manage_fee_view.dart';
import '../modules/school_admin/views/student_fee_details_view.dart';
import '../modules/school_admin/views/reports_view.dart';
import '../modules/school_admin/views/archived_students_view.dart';
import '../modules/school_admin/views/archived_teachers_view.dart';
import '../modules/school_admin/views/archive_report_detail_view.dart';
import '../modules/school_admin/views/register_teacher_view.dart';
import '../modules/school_admin/views/enrolled_teachers_view.dart';
import '../modules/school_admin/views/teacher_timetable_view.dart';
import '../modules/school_admin/views/teacher_detail_view.dart';
import '../modules/school_admin/views/schedule_exam_view.dart';
import '../modules/school_admin/views/exam_schedule_detail_view.dart';
import '../modules/school_admin/views/class_timetable_view.dart';
import '../modules/school_admin/views/admin_notifications_view.dart';
import '../modules/school_admin/views/admin_notification_detail_view.dart';
import '../modules/school_admin/views/admin_archive_queue_view.dart';
import '../modules/school_admin/views/archived_student_detail_view.dart';
import '../modules/school_admin/views/admin_notifications_hub_view.dart';
import '../modules/school_admin/views/create_notification_view.dart';
import '../modules/school_admin/views/sent_notifications_view.dart';
import '../modules/school_admin/views/notification_detail_view.dart';
import '../modules/teacher/bindings/teacher_binding.dart';
import '../modules/teacher/views/teacher_dashboard_view.dart';
import '../modules/teacher/views/teacher_profile_view.dart';
import '../modules/teacher/views/teacher_attendance_classes_view.dart';
import '../modules/teacher/views/teacher_attendance_grid_view.dart';
import '../modules/teacher/views/teacher_results_classes_view.dart';
import '../modules/teacher/views/teacher_result_matrix_view.dart';
import '../modules/teacher/views/teacher_notifications_view.dart';
import '../modules/teacher/views/teacher_timetable_view.dart'
    as teacher_timetable;
import '../modules/teacher/views/teacher_students_view.dart';
import '../modules/teacher/views/teacher_exam_view.dart';
import '../modules/teacher/views/teacher_analytics_view.dart';
import '../modules/teacher/views/teacher_settings_view.dart';
import '../modules/teacher/views/teacher_reports_view.dart';
import '../modules/teacher/views/teacher_search_view.dart';
import '../modules/teacher/views/teacher_inbox_view.dart';
import '../modules/teacher/views/teacher_chat_view.dart';
import '../modules/student/bindings/student_binding.dart';
import '../modules/student/views/student_dashboard_view.dart';
import '../modules/student/views/student_attendance_view.dart';
import '../modules/student/views/student_attendance_detail_view.dart';
import '../modules/student/views/student_fee_detail_view.dart';
import '../modules/student/views/student_assignment_detail_view.dart';
import '../modules/student/views/student_result_detail_view.dart';
import '../modules/student/views/student_chat_view.dart';
import '../modules/student/views/student_announcement_detail_view.dart';
import '../modules/student/views/student_exam_detail_view.dart';
import '../modules/student/views/student_exam_view.dart';
import '../modules/student/views/student_timetable_view.dart';
import '../modules/school_admin/views/admin_school_profile_view.dart';
import '../modules/school_admin/views/student_detail_view.dart';

// Parent Module Imports (ADDITIVE - FRS Requirement)
import '../modules/parent/bindings/parent_binding.dart';
import '../modules/parent/views/parent_select_student_view.dart';
import '../modules/parent/views/parent_dashboard_view.dart';
import '../modules/parent/views/parent_profile_view.dart';
import '../modules/public/bindings/public_ranking_binding.dart';
import '../modules/public/views/public_ranking_view.dart';
import '../modules/public/views/public_school_detail_view.dart';
import '../modules/dashboard/views/super_admin_notifications_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppPaths.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppPaths.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppPaths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppPaths.superAdminDashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppPaths.registerSchool,
      page: () => const RegisterSchoolView(),
      binding: SchoolBinding(),
    ),
    GetPage(
      name: AppPaths.schoolDetail,
      page: () => const SchoolDetailView(),
      binding: SchoolBinding(),
    ),
    GetPage(
      name: AppPaths.backup,
      page: () => const BackupView(),
      binding: SystemBinding(),
    ),
    GetPage(
      name: AppPaths.restore,
      page: () => const RestoreView(),
      binding: SystemBinding(),
    ),
    GetPage(
      name: AppPaths.message,
      page: () => const MessageView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: AppPaths.auditLogs,
      page: () => const AuditLogView(),
      binding: SystemBinding(),
    ),
    GetPage(
      name: AppPaths.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppPaths.profile,
      page: () => const ProfileView(),
      binding: SystemBinding(),
    ),
    // School Admin Pages
    GetPage(
      name: AppPaths.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminManageStudents,
      page: () => const ManageStudentsByClassView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminManageTeachers,
      page: () => const ManageTeachersView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminManageExams,
      page: () => const ManageExamsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminReportsHub,
      page: () => const ReportsHubView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminClassTimetableHub,
      page: () => const ClassTimetableHubView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminViewEnrolledStudents,
      page: () => const ViewEnrolledStudentsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminRegisterStudent,
      page: () => const RegisterStudentView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminCreateClass,
      page: () => const CreateClassView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminCreatePassword,
      page: () => const CreatePasswordView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminManageFee,
      page: () => const ManageFeeView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminStudentFeeDetails,
      page: () => const StudentFeeDetailsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminReports,
      page: () => const ReportsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminArchivedStudents,
      page: () => const ArchivedStudentsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminArchivedTeachers,
      page: () => const ArchivedTeachersView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminArchiveReportDetail,
      page: () => const ArchiveReportDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminRegisterTeacher,
      page: () => const RegisterTeacherView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminEnrolledTeachers,
      page: () => const EnrolledTeachersView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminTeacherTimetable,
      page: () => const TeacherTimetableView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminTeacherDetail,
      page: () => const TeacherDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminScheduleExam,
      page: () => const ScheduleExamView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminExamScheduleDetail,
      page: () => const ExamScheduleDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminClassTimetable,
      page: () => const ClassTimetableView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminNotifications,
      page: () => const AdminNotificationsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminNotificationDetail,
      page: () => const AdminNotificationDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminArchiveQueue,
      page: () => const AdminArchiveQueueView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminManageSubjects,
      page: () => const ManageSubjectsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminSubjectPerformance,
      page: () => const SubjectPerformanceView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminTeacherAssignment,
      page: () => const TeacherAssignmentView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminArchivedStudentDetail,
      page: () => const ArchivedStudentDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminNotificationsHub,
      page: () => const AdminNotificationsHubView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminCreateNotification,
      page: () => const CreateNotificationView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminSentNotifications,
      page: () => const SentNotificationsView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminNotificationDetailSent,
      page: () => const NotificationDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminStudentDetail,
      page: () => const StudentDetailView(),
      binding: SchoolAdminBinding(),
    ),
    GetPage(
      name: AppPaths.adminProfile,
      page: () => const AdminSchoolProfileView(),
      binding: SchoolAdminBinding(),
    ),
    // Teacher Module Pages
    GetPage(
      name: AppPaths.teacherDashboard,
      page: () => const TeacherDashboardView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherProfile,
      page: () => const TeacherProfileView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherAttendanceClasses,
      page: () => const TeacherAttendanceClassesView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherAttendanceMark,
      page: () => const TeacherAttendanceGridView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherResultsClasses,
      page: () => const TeacherResultsClassesView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherResultsMark,
      page: () => const TeacherResultMatrixView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherNotifications,
      page: () => const TeacherNotificationsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherTimetable,
      page: () => const teacher_timetable.TeacherTimetableView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherMyStudents,
      page: () => const TeacherStudentsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherAnalytics,
      page: () => const TeacherAnalyticsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherSettings,
      page: () => const TeacherSettingsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherReports,
      page: () => const TeacherReportsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherSearch,
      page: () => const TeacherSearchView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherInbox,
      page: () => const TeacherInboxView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherChat,
      page: () => const TeacherChatView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppPaths.teacherExams,
      page: () => const TeacherExamView(),
      binding: TeacherBinding(),
    ),
    // Student Module Pages
    GetPage(
      name: AppPaths.studentDashboard,
      page: () => const StudentDashboardView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentAttendance,
      page: () => const StudentAttendanceView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentAttendanceDetail,
      page: () => const StudentAttendanceDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentFeeDetail,
      page: () => const StudentFeeDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentAssignmentDetail,
      page: () => const StudentAssignmentDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentResultDetail,
      page: () => const StudentResultDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentChat,
      page: () => const StudentChatView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentAnnouncementDetail,
      page: () => const StudentAnnouncementDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentExamDetail,
      page: () => const StudentExamDetailView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentExams,
      page: () => const StudentExamView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppPaths.studentTimetable,
      page: () => const StudentTimetableView(),
      binding: StudentBinding(),
    ),

    // Parent Module Pages (ADDITIVE - FRS Requirement)
    GetPage(
      name: AppPaths.parentSelectStudent,
      page: () => const ParentSelectStudentView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppPaths.parentDashboard,
      page: () => const ParentDashboardView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppPaths.parentProfile,
      page: () => const ParentProfileView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppPaths.publicRanking,
      page: () => const PublicRankingView(),
      binding: PublicRankingBinding(),
    ),
    GetPage(
      name: AppPaths.publicSchoolDetail,
      page: () => const PublicSchoolDetailView(),
    ),
    GetPage(
      name: AppPaths.superAdminNotifications,
      page: () => const SuperAdminNotificationsView(),
      binding: DashboardBinding(),
    ),
    GetPage(name: AppPaths.restricted, page: () => const RestrictedView()),
  ];
}
