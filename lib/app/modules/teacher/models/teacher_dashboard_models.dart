import '../../school_admin/models/school_admin_models.dart';


class TeacherDashboardData {
  final TeacherModel teacherProfile;
  final List<ClassTimetableSlotModel> todayTimetable;
  final List<ClassTimetableSlotModel> upcomingTimetable;
  final TeacherStats stats;
  final String schoolName;
  final double rating;

  TeacherDashboardData({
    required this.teacherProfile,
    required this.todayTimetable,
    required this.upcomingTimetable,
    required this.stats,
    required this.schoolName,
    required this.rating,
  });

  String get teacherName => teacherProfile.name;
  String get qualification => teacherProfile.qualification;
  List<ClassTimetableSlotModel> get todayClasses => todayTimetable;
  List<ClassTimetableSlotModel> get upcomingClasses => upcomingTimetable;

  Map<String, dynamic> toJson() => {
    'teacherProfile': teacherProfile.toJson(),
    'todayTimetable': todayTimetable.map((e) => e.toJson()).toList(),
    'upcomingTimetable': upcomingTimetable.map((e) => e.toJson()).toList(),
    'stats': stats.toJson(),
    'schoolName': schoolName,
    'rating': rating,
  };

  factory TeacherDashboardData.fromJson(Map<String, dynamic> json) =>
      TeacherDashboardData(
        teacherProfile: TeacherModel.fromJson(json['teacherProfile']),
        todayTimetable: (json['todayTimetable'] as List? ?? [])
            .map((e) => ClassTimetableSlotModel.fromJson(e))
            .toList(),
        upcomingTimetable: (json['upcomingTimetable'] as List? ?? [])
            .map((e) => ClassTimetableSlotModel.fromJson(e))
            .toList(),
        stats: TeacherStats.fromJson(json['stats']),
        schoolName: json['schoolName'],
        rating: json['rating'],
      );
}

class TeacherStats {
  final int totalStudents;
  final int totalClasses;
  final int pendingAssignments;

  TeacherStats({
    required this.totalStudents,
    required this.totalClasses,
    required this.pendingAssignments,
  });

  Map<String, dynamic> toJson() => {
    'totalStudents': totalStudents,
    'totalClasses': totalClasses,
    'pendingAssignments': pendingAssignments,
  };

  factory TeacherStats.fromJson(Map<String, dynamic> json) => TeacherStats(
    totalStudents: json['totalStudents'],
    totalClasses: json['totalClasses'],
    pendingAssignments: json['pendingAssignments'],
  );
}
