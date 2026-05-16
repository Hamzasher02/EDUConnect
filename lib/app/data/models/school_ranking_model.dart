import '../enums/app_enums.dart';

class SchoolRankingModel {
  final String schoolId;
  final String schoolName;
  final String? schoolLogoUrl;
  final String address;
  final String city;
  final SchoolCategory category;
  final double overallScore; // 0-100
  final double academicPerformanceScore;
  final double teacherQualificationScore;
  final double attendanceScore;
  final int totalTeachers;
  final int totalStudents;
  final bool isVisible; // Hide/show ranking toggle
  final DateTime lastCalculatedAt;
  final List<String> subjectsOffered;
  final String? whatsappNumber; // For contact school button

  SchoolRankingModel({
    required this.schoolId,
    required this.schoolName,
    this.schoolLogoUrl,
    required this.address,
    required this.city,
    required this.category,
    required this.overallScore,
    required this.academicPerformanceScore,
    required this.teacherQualificationScore,
    required this.attendanceScore,
    required this.totalTeachers,
    required this.totalStudents,
    this.isVisible = true,
    required this.lastCalculatedAt,
    this.subjectsOffered = const [],
    this.whatsappNumber,
  });

  SchoolRankingModel copyWith({
    String? schoolId,
    String? schoolName,
    String? schoolLogoUrl,
    String? address,
    String? city,
    SchoolCategory? category,
    double? overallScore,
    double? academicPerformanceScore,
    double? teacherQualificationScore,
    double? attendanceScore,
    int? totalTeachers,
    int? totalStudents,
    bool? isVisible,
    DateTime? lastCalculatedAt,
    List<String>? subjectsOffered,
    String? whatsappNumber,
  }) {
    return SchoolRankingModel(
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolLogoUrl: schoolLogoUrl ?? this.schoolLogoUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      category: category ?? this.category,
      overallScore: overallScore ?? this.overallScore,
      academicPerformanceScore:
          academicPerformanceScore ?? this.academicPerformanceScore,
      teacherQualificationScore:
          teacherQualificationScore ?? this.teacherQualificationScore,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalStudents: totalStudents ?? this.totalStudents,
      isVisible: isVisible ?? this.isVisible,
      lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
      subjectsOffered: subjectsOffered ?? this.subjectsOffered,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'schoolName': schoolName,
    'schoolLogoUrl': schoolLogoUrl,
    'address': address,
    'city': city,
    'category': category.name,
    'overallScore': overallScore,
    'academicPerformanceScore': academicPerformanceScore,
    'teacherQualificationScore': teacherQualificationScore,
    'attendanceScore': attendanceScore,
    'totalTeachers': totalTeachers,
    'totalStudents': totalStudents,
    'isVisible': isVisible,
    'lastCalculatedAt': lastCalculatedAt.toIso8601String(),
    'subjectsOffered': subjectsOffered,
    'whatsappNumber': whatsappNumber,
  };

  factory SchoolRankingModel.fromJson(Map<String, dynamic> json) {
    return SchoolRankingModel(
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
      schoolLogoUrl: json['schoolLogoUrl'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      category: SchoolCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SchoolCategory.improving,
      ),
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      academicPerformanceScore: (json['academicPerformanceScore'] ?? 0)
          .toDouble(),
      teacherQualificationScore: (json['teacherQualificationScore'] ?? 0)
          .toDouble(),
      attendanceScore: (json['attendanceScore'] ?? 0).toDouble(),
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      lastCalculatedAt: DateTime.parse(json['lastCalculatedAt']),
      subjectsOffered: json['subjectsOffered'] != null
          ? List<String>.from(json['subjectsOffered'])
          : [],
      whatsappNumber: json['whatsappNumber'],
    );
  }
}
