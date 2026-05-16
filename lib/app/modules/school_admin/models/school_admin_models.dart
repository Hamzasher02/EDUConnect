import 'package:flutter/material.dart';
import '../../../data/models/fee_model.dart';
import '../../../data/models/parent_model.dart';

export '../../../data/models/student_model.dart';
export '../../../data/models/teacher_model.dart';
export '../../../data/enums/app_enums.dart';
export '../../../data/models/fee_model.dart';
export '../../../data/models/messaging/notification_model.dart';
export '../../../data/models/parent_model.dart';
export '../../../data/models/attendance_assignment_models.dart';

typedef MonthlyFeeRecordModel = FeeRecordModel;
typedef ParentAccountModel = ParentModel;

enum InvitationRole { parent, teacher, schoolAdmin }

class InvitationModel {
  String token; // UUID as ID
  InvitationRole role;
  String email;
  String schoolId;
  String? cnic;
  String? targetStudentId;
  DateTime createdAt;
  DateTime expiresAt;
  bool isUsed;

  InvitationModel({
    required this.token,
    required this.role,
    required this.email,
    required this.schoolId,
    this.cnic,
    this.targetStudentId,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });
}

// --- Reports & Archives ---

enum ReportStatusFilter { all, active, inactive, archived }

class TeacherAssignedClassModel {
  String id;
  String teacherId;
  String classNumber; // 9, 10, 11, 12
  String subjectName;
  String roomNumber;
  String day; // Mon, Tue, ...
  TimeOfDay startTime;
  TimeOfDay endTime;

  TeacherAssignedClassModel({
    required this.id,
    required this.teacherId,
    required this.classNumber,
    required this.subjectName,
    required this.roomNumber,
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}

class StudentArchiveReportModel {
  String studentId;
  String name;
  String rollNo;
  String classNumber;
  String parentEmail;
  String parentCnic;
  DateTime joiningDate;
  DateTime? struckOffDate;
  double lastFeeSummary;
  String attendanceSummary;
  DateTime generatedAt;

  StudentArchiveReportModel({
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.classNumber,
    required this.parentEmail,
    required this.parentCnic,
    required this.joiningDate,
    this.struckOffDate,
    required this.lastFeeSummary,
    required this.attendanceSummary,
    required this.generatedAt,
  });
}

class TeacherArchiveReportModel {
  String teacherId;
  String name;
  String subject;
  String qualification;
  int experienceYears;
  List<String> classesTaught;
  DateTime joiningDate;
  DateTime? removedDate;
  DateTime generatedAt;

  TeacherArchiveReportModel({
    required this.teacherId,
    required this.name,
    required this.subject,
    required this.qualification,
    required this.experienceYears,
    required this.classesTaught,
    required this.joiningDate,
    this.removedDate,
    required this.generatedAt,
  });
}

class ExamSubjectScheduleModel {
  String id;
  String subjectName;
  DateTime examDate;
  TimeOfDay examTime;

  ExamSubjectScheduleModel({
    required this.id,
    required this.subjectName,
    required this.examDate,
    required this.examTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectName': subjectName,
    'examDate': examDate.toIso8601String(),
    'examTime': '${examTime.hour}:${examTime.minute}',
  };

  factory ExamSubjectScheduleModel.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['examTime'] as String).split(':');
    return ExamSubjectScheduleModel(
      id: json['id'],
      subjectName: json['subjectName'],
      examDate: DateTime.parse(json['examDate']),
      examTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}

class ExamScheduleModel {
  String id;
  String schoolId; // Mock: "school_001"
  String classNumber;
  String academicYear;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy; // Admin ID mock
  List<ExamSubjectScheduleModel> subjects;

  ExamScheduleModel({
    required this.id,
    required this.schoolId,
    required this.classNumber,
    required this.academicYear,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.subjects,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'classNumber': classNumber,
    'academicYear': academicYear,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'subjects': subjects.map((s) => s.toJson()).toList(),
  };

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) {
    return ExamScheduleModel(
      id: json['id'],
      schoolId: json['schoolId'],
      classNumber: json['classNumber'],
      academicYear: json['academicYear'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      subjects: (json['subjects'] as List)
          .map((s) => ExamSubjectScheduleModel.fromJson(s))
          .toList(),
    );
  }

  /// Check if schedule is locked (any exam date has passed)
  bool get isLocked {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (var subject in subjects) {
      final examDateOnly = DateTime(
        subject.examDate.year,
        subject.examDate.month,
        subject.examDate.day,
      );
      if (examDateOnly.isBefore(todayDate)) {
        return true;
      }
    }
    return false;
  }
}

class ClassTimetableSlotModel {
  String id;
  String classId;
  String classNumber;
  String day;
  String subjectId;
  String subjectName;
  String? teacherId;
  String teacherName;
  String startTime;
  String endTime;
  String roomNumber;

  ClassTimetableSlotModel({
    required this.id,
    required this.classId,
    required this.classNumber,
    required this.day,
    required this.subjectId,
    required this.subjectName,
    this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'classNumber': classNumber,
    'day': day,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'startTime': startTime,
    'endTime': endTime,
    'roomNumber': roomNumber,
  };

  factory ClassTimetableSlotModel.fromJson(Map<String, dynamic> json) =>
      ClassTimetableSlotModel(
        id: json['id'],
        classId: json['classId'],
        classNumber: json['classNumber'],
        day: json['day'],
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        teacherId: json['teacherId'],
        teacherName: json['teacherName'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        roomNumber: json['roomNumber'],
      );
}

class StudentSummaryReportModel {
  String id;
  String studentId;
  String name;
  String rollNo;
  String classNumber;
  String parentEmail;
  String parentCnic;
  String contactNumber;
  String address;
  DateTime joiningDate;
  DateTime? inactiveAt;
  DateTime? archivedAt;
  String feeSummaryText;
  String attendanceSummaryText;
  DateTime generatedAt;
  String generatedByRole;

  StudentSummaryReportModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.classNumber,
    required this.parentEmail,
    required this.parentCnic,
    required this.contactNumber,
    required this.address,
    required this.joiningDate,
    this.inactiveAt,
    this.archivedAt,
    required this.feeSummaryText,
    required this.attendanceSummaryText,
    required this.generatedAt,
    this.generatedByRole = 'School Admin',
  });
}
