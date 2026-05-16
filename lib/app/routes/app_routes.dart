// Removed part of 'app_pages.dart' to allow direct imports

abstract class AppPaths {
  AppPaths._();
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';
  static const superAdminDashboard = '/super-admin-dashboard';
  static const registerSchool = '/register-school';
  static const schoolDetail = '/school-detail';
  static const backup = '/backup';
  static const restore = '/restore';
  static const message = '/message';
  static const auditLogs = '/audit-logs';
  static const profile = '/profile';
  static const restricted = '/restricted';

  // School Admin Paths
  static const adminDashboard = '/admin-dashboard';
  static const adminManageStudents = '/admin-manage-students';
  static const adminManageTeachers = '/admin-manage-teachers';
  static const adminManageExams = '/admin-manage-exams';
  static const adminReportsHub = '/admin-reports-hub';
  static const adminClassTimetableHub = '/admin-class-timetable-hub';
  static const adminViewEnrolledStudents = '/admin-view-enrolled-students';
  static const adminRegisterStudent = '/admin-register-student';
  static const adminCreateClass = '/admin-create-class';
  static const adminCreatePassword = '/admin-create-password';
  static const adminManageFee = '/admin-manage-fee';
  static const adminStudentFeeDetails = '/admin-student-fee-details';
  static const adminReports = '/admin-reports';
  static const adminArchivedStudents = '/admin-archived-students';
  static const adminArchivedTeachers = '/admin-archived-teachers';
  static const adminArchiveReportDetail = '/admin-archive-report-detail';
  static const adminRegisterTeacher = '/admin-register-teacher';
  static const adminEnrolledTeachers = '/admin-enrolled-teachers';
  static const adminTeacherTimetable = '/admin-teacher-timetable';
  static const adminTeacherDetail = '/admin-teacher-detail';
  static const adminScheduleExam = '/admin-schedule-exam';
  static const adminExamScheduleDetail = '/admin-exam-schedule-detail';
  static const adminClassTimetable = '/admin-class-timetable';
  static const adminNotifications = '/admin-notifications';
  static const adminNotificationDetail = '/admin-notification-detail';
  static const adminArchiveQueue = '/admin-archive-queue';
  static const adminManageSubjects = '/admin-manage-subjects';
  static const adminTeacherAssignment = '/admin-teacher-assignment';
  static const adminArchivedStudentDetail = '/admin-archived-student-detail';
  static const adminNotificationsHub = '/admin-notifications-hub';
  static const adminCreateNotification = '/admin-create-notification';
  static const adminSentNotifications = '/admin-sent-notifications';
  static const adminStudentDetail = '/admin-student-detail';
  static const adminNotificationDetailSent = '/admin-notification-detail-sent';
  static const adminProfile = '/admin-profile';
  static const adminSubjectPerformance = '/admin-subject-performance';

  // Teacher Module Paths
  static const teacherDashboard = '/teacher-dashboard';
  static const teacherProfile = '/teacher-profile';
  static const teacherAttendanceClasses = '/teacher-attendance-classes';
  static const teacherAttendanceMark = '/teacher-attendance-mark';
  static const teacherResultsClasses = '/teacher-results-classes';
  static const teacherResultsMark = '/teacher-results-mark';
  static const teacherNotifications = '/teacher-notifications';
  static const teacherTimetable = '/teacher-timetable';
  static const teacherMyStudents = '/teacher-my-students';
  static const teacherAnalytics = '/teacher-analytics';
  static const teacherSettings = '/teacher-settings';
  static const teacherReports = '/teacher-reports';
  static const teacherSearch = '/teacher-search';
  static const teacherInbox = '/teacher-inbox';
  static const teacherChat = '/teacher-chat';
  static const teacherExams = '/teacher-exams';

  // Student Module Paths
  static const studentDashboard = '/student-dashboard';
  static const studentAttendance = '/student-attendance';
  static const studentAttendanceDetail = '/student-attendance-detail';
  static const studentFeeDetail = '/student-fee-detail';
  static const studentAssignmentDetail = '/student-assignment-detail';
  static const studentResultDetail = '/student-result-detail';
  static const studentChat = '/student-chat';
  static const studentAnnouncementDetail = '/student-announcement-detail';
  static const studentExamDetail = '/student-exam-detail';
  static const studentExams = '/student-exams';
  static const studentTimetable = '/student-timetable';
  static const parentDashboard = '/parent-dashboard';
  static const superAdminNotifications = '/super-admin-notifications';

  // Parent Module Paths (ADDITIVE - FRS Requirement)
  static const parentSelectStudent = '/parent-select-student';
  static const parentProfile = '/parent-profile';

  // Public Access Module Paths (ADDITIVE - FRS Requirement)
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const publicRanking = '/public-ranking';
  static const publicSchoolDetail = '/public-school-detail';
}

abstract class AppRoutes {
  AppRoutes._();
  static const login = AppPaths.login;
  static const signup = AppPaths.signup;
  static const dashboard = AppPaths.dashboard;
  static const superAdminDashboard = AppPaths.superAdminDashboard;
  static const registerSchool = AppPaths.registerSchool;
  static const schoolDetail = AppPaths.schoolDetail;
  static const backup = AppPaths.backup;
  static const restore = AppPaths.restore;
  static const message = AppPaths.message;
  static const auditLogs = AppPaths.auditLogs;
  static const profile = AppPaths.profile;
  static const restricted = AppPaths.restricted;

  // School Admin Routes
  static const adminDashboard = AppPaths.adminDashboard;
  static const adminManageStudents = AppPaths.adminManageStudents;
  static const adminManageTeachers = AppPaths.adminManageTeachers;
  static const adminManageExams = AppPaths.adminManageExams;
  static const adminReportsHub = AppPaths.adminReportsHub;
  static const adminClassTimetableHub = AppPaths.adminClassTimetableHub;
  static const adminViewEnrolledStudents = AppPaths.adminViewEnrolledStudents;
  static const adminRegisterStudent = AppPaths.adminRegisterStudent;
  static const adminCreateClass = AppPaths.adminCreateClass;
  static const adminCreatePassword = AppPaths.adminCreatePassword;
  static const adminManageFee = AppPaths.adminManageFee;
  static const adminStudentFeeDetails = AppPaths.adminStudentFeeDetails;
  static const adminReports = AppPaths.adminReports;
  static const adminArchivedStudents = AppPaths.adminArchivedStudents;
  static const adminArchivedTeachers = AppPaths.adminArchivedTeachers;
  static const adminArchiveReportDetail = AppPaths.adminArchiveReportDetail;
  static const adminRegisterTeacher = AppPaths.adminRegisterTeacher;
  static const adminEnrolledTeachers = AppPaths.adminEnrolledTeachers;
  static const adminTeacherTimetable = AppPaths.adminTeacherTimetable;
  static const adminTeacherDetail = AppPaths.adminTeacherDetail;
  static const adminScheduleExam = AppPaths.adminScheduleExam;
  static const adminExamScheduleDetail = AppPaths.adminExamScheduleDetail;
  static const adminClassTimetable = AppPaths.adminClassTimetable;
  static const adminNotifications = AppPaths.adminNotifications;
  static const adminNotificationDetail = AppPaths.adminNotificationDetail;
  static const adminArchiveQueue = AppPaths.adminArchiveQueue;
  static const adminManageSubjects = AppPaths.adminManageSubjects;
  static const adminTeacherAssignment = AppPaths.adminTeacherAssignment;
  static const adminArchivedStudentDetail = AppPaths.adminArchivedStudentDetail;
  static const adminNotificationsHub = AppPaths.adminNotificationsHub;
  static const adminCreateNotification = AppPaths.adminCreateNotification;
  static const adminSentNotifications = AppPaths.adminSentNotifications;
  static const adminStudentDetail = AppPaths.adminStudentDetail;
  static const adminNotificationDetailSent =
      AppPaths.adminNotificationDetailSent;
  static const adminProfile = AppPaths.adminProfile;
  static const adminSubjectPerformance = AppPaths.adminSubjectPerformance;
  static const parentDashboard = AppPaths.parentDashboard;
  static const superAdminNotifications = AppPaths.superAdminNotifications;

  // Parent Module Routes (ADDITIVE - FRS Requirement)
  static const parentSelectStudent = AppPaths.parentSelectStudent;
  static const parentProfile = AppPaths.parentProfile;

  // Public Access Module Routes (ADDITIVE - FRS Requirement)
  static const splash = AppPaths.splash;
  static const welcome = AppPaths.welcome;
  static const publicRanking = AppPaths.publicRanking;
  static const publicSchoolDetail = AppPaths.publicSchoolDetail;

  // Teacher Module Routes
  static const teacherDashboard = AppPaths.teacherDashboard;
  static const teacherProfile = AppPaths.teacherProfile;
  static const teacherAttendanceClasses = AppPaths.teacherAttendanceClasses;
  static const teacherAttendanceMark = AppPaths.teacherAttendanceMark;
  static const teacherResultsClasses = AppPaths.teacherResultsClasses;
  static const teacherResultsMark = AppPaths.teacherResultsMark;
  static const teacherNotifications = AppPaths.teacherNotifications;
  static const teacherTimetable = AppPaths.teacherTimetable;
  static const teacherMyStudents = AppPaths.teacherMyStudents;
  static const teacherAnalytics = AppPaths.teacherAnalytics;
  static const teacherSettings = AppPaths.teacherSettings;
  static const teacherReports = AppPaths.teacherReports;
  static const teacherSearch = AppPaths.teacherSearch;
  static const teacherInbox = AppPaths.teacherInbox;
  static const teacherChat = AppPaths.teacherChat;
  static const teacherExams = AppPaths.teacherExams;

  // Student Module Routes
  static const studentDashboard = AppPaths.studentDashboard;
  static const studentAttendance = AppPaths.studentAttendance;
  static const studentAttendanceDetail = AppPaths.studentAttendanceDetail;
  static const studentFeeDetail = AppPaths.studentFeeDetail;
  static const studentAssignmentDetail = AppPaths.studentAssignmentDetail;
  static const studentResultDetail = AppPaths.studentResultDetail;
  static const studentChat = AppPaths.studentChat;
  static const studentAnnouncementDetail = AppPaths.studentAnnouncementDetail;
  static const studentExamDetail = AppPaths.studentExamDetail;
  static const studentExams = AppPaths.studentExams;
  static const studentTimetable = AppPaths.studentTimetable;
}
