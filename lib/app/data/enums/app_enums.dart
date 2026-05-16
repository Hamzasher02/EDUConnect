enum UserRole { superAdmin, schoolAdmin, teacher, parent, student }

enum FeeStatus { paid, pending, overdue, due, processing }

enum NotificationType {
  announcement,
  alert,
  fee,
  exam,
  attendance,
  system,
  message,
}

enum NotificationAudience {
  wholeSchool,
  classOnly,
  specificStudent,
  specificTeacher,
  parents,
  teachers,
  students,
}

enum NotificationStatus { sent, draft }

enum StudentLifecycleStatus { active, inactive, archived, deleted }

enum TeacherLifecycleStatus { active, inactive, archived, deleted }

enum ExamType { term, unit, finalExam, quiz }

enum AssessmentCategory { exam, assignment, quiz, project, custom }

enum SchoolCategory { excellent, good, improving, unrated }

enum SubmissionStatus { onTime, late, missing, graded, submitted, pending }

enum SubjectAttendanceStatus { present, absent, late, excused }

enum TransactionStatus { successful, failed, processing, pending }
