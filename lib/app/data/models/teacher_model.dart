import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

class TeacherModel {
  final String id;
  final String schoolId;
  final String name;
  final String email;
  final String qualification;
  final String subjectSpecialization;
  final int experienceYears;
  final String contactNumber;
  final String? profilePhotoUrl;
  TeacherLifecycleStatus lifecycleStatus;
  bool isActive;
  bool isPasswordCreated;
  final String? password;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? removedAt;

  final List<String> qualifications;
  final String? address;
  final String? bloodGroup;
  final List<String> subjectsTaught;

  TeacherModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.email,
    required this.qualification,
    required this.subjectSpecialization,
    required this.experienceYears,
    required this.contactNumber,
    this.profilePhotoUrl,
    this.password,
    this.lifecycleStatus = TeacherLifecycleStatus.active,
    this.isActive = true,
    this.isPasswordCreated = false,
    required this.createdAt,
    required this.updatedAt,
    this.removedAt,
    this.qualifications = const [],
    this.address,
    this.bloodGroup,
    this.subjectsTaught = const [],
  });

  TeacherModel copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? email,
    String? qualification,
    String? subjectSpecialization,
    int? experienceYears,
    String? contactNumber,
    String? profilePhotoUrl,
    String? password,
    bool? isActive,
    bool? isPasswordCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? removedAt,
    List<String>? qualifications,
    String? address,
    String? bloodGroup,
    List<String>? subjectsTaught,
    TeacherLifecycleStatus? lifecycleStatus,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      email: email ?? this.email,
      qualification: qualification ?? this.qualification,
      subjectSpecialization:
          subjectSpecialization ?? this.subjectSpecialization,
      experienceYears: experienceYears ?? this.experienceYears,
      contactNumber: contactNumber ?? this.contactNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      isPasswordCreated: isPasswordCreated ?? this.isPasswordCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      removedAt: removedAt ?? this.removedAt,
      qualifications: qualifications ?? this.qualifications,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      subjectsTaught: subjectsTaught ?? this.subjectsTaught,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'name': name,
    'email': email,
    'qualification': qualification,
    'subjectSpecialization': subjectSpecialization,
    'experienceYears': experienceYears,
    'contactNumber': contactNumber,
    'profilePhotoUrl': profilePhotoUrl,
    'lifecycleStatus': lifecycleStatus.name,
    'isActive': isActive,
    'isPasswordCreated': isPasswordCreated,
    'password': password,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'removedAt': removedAt?.toIso8601String(),
    'qualifications': qualifications,
    'address': address,
    'bloodGroup': bloodGroup,
    'subjectsTaught': subjectsTaught,
  };

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      schoolId: json['schoolId'],
      name: json['name'],
      email: json['email'],
      qualification: json['qualification'],
      subjectSpecialization: json['subjectSpecialization'],
      experienceYears: json['experienceYears'] ?? 0,
      contactNumber: json['contactNumber'],
      profilePhotoUrl: json['profilePhotoUrl'],
      lifecycleStatus: TeacherLifecycleStatus.values.firstWhere(
        (e) => e.name == (json['lifecycleStatus'] ?? 'active'),
        orElse: () => TeacherLifecycleStatus.active,
      ),
      isActive: json['isActive'] ?? true,
      isPasswordCreated: json['isPasswordCreated'] ?? false,
      password: json['password'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'])
                : (json['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'])
                : (json['updatedAt'] as Timestamp).toDate())
          : DateTime.now(),
      removedAt: json['removedAt'] != null
          ? (json['removedAt'] is String
                ? DateTime.parse(json['removedAt'])
                : (json['removedAt'] as Timestamp).toDate())
          : null,
      qualifications: List<String>.from(json['qualifications'] ?? []),
      address: json['address'],
      bloodGroup: json['bloodGroup'],
      subjectsTaught: List<String>.from(json['subjectsTaught'] ?? []),
    );
  }
}

class TeacherSettingsModel {
  final bool notificationsEnabled;
  final bool emailAlerts;
  final String themeMode; // 'system', 'light', 'dark'
  final String language;
  final int refreshInterval;
  final DateTime? lastExportTimestamp;

  TeacherSettingsModel({
    this.notificationsEnabled = true,
    this.emailAlerts = true,
    this.themeMode = 'system',
    this.language = 'en',
    this.refreshInterval = 15,
    this.lastExportTimestamp,
  });

  TeacherSettingsModel copyWith({
    bool? notificationsEnabled,
    bool? emailAlerts,
    String? themeMode,
    String? language,
    int? refreshInterval,
    DateTime? lastExportTimestamp,
  }) {
    return TeacherSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      lastExportTimestamp: lastExportTimestamp ?? this.lastExportTimestamp,
    );
  }

  factory TeacherSettingsModel.fromJson(Map<String, dynamic> json) {
    return TeacherSettingsModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailAlerts: json['emailAlerts'] ?? true,
      themeMode: json['themeMode'] ?? 'system',
      language: json['language'] ?? 'en',
      refreshInterval: json['refreshInterval'] ?? 15,
      lastExportTimestamp: json['lastExportTimestamp'] != null
          ? DateTime.parse(json['lastExportTimestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'emailAlerts': emailAlerts,
    'themeMode': themeMode,
    'language': language,
    'refreshInterval': refreshInterval,
    'lastExportTimestamp': lastExportTimestamp?.toIso8601String(),
  };
}
