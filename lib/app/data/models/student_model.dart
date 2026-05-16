import '../enums/app_enums.dart';

class ClassModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class StudentModel {
  final String id;
  final String schoolId;
  final String name;
  final String rollNo;
  final String classNumber;
  final String? photoUrl;
  bool isStruckOff;
  bool canStudentLogin;
  bool canParentView;

  // Additional detail fields for reports
  final String parentEmail;
  final String parentCnic;
  final String? contactNumber;
  final String? address;
  final DateTime? admissionDate;

  // Student login credentials
  final String? email;
  final String? password;
  bool isPasswordCreated;
  final DateTime? createdAt;

  // Lifecycle management fields
  StudentLifecycleStatus lifecycleStatus;
  DateTime? inactiveAt;
  DateTime? archivedAt;
  DateTime? deleteEligibleAt;
  DateTime? deletedAt;

  StudentModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.rollNo,
    required this.classNumber,
    this.photoUrl,
    this.isStruckOff = false,
    this.canStudentLogin = true,
    this.canParentView = true,
    this.email,
    this.password,
    this.isPasswordCreated = false,
    this.createdAt,
    this.parentEmail = '',
    this.parentCnic = '',
    this.contactNumber,
    this.address,
    this.admissionDate,
    this.lifecycleStatus = StudentLifecycleStatus.active,
    this.inactiveAt,
    this.archivedAt,
    this.deleteEligibleAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'name': name,
    'rollNo': rollNo,
    'classNumber': classNumber,
    'photoUrl': photoUrl,
    'isStruckOff': isStruckOff,
    'canStudentLogin': canStudentLogin,
    'canParentView': canParentView,
    'email': email,
    'isPasswordCreated': isPasswordCreated,
    'createdAt': createdAt?.toIso8601String(),
    'parentEmail': parentEmail,
    'parentCnic': parentCnic,
    'contactNumber': contactNumber,
    'address': address,
    'admissionDate': admissionDate?.toIso8601String(),
    'lifecycleStatus': lifecycleStatus.name,
    'inactiveAt': inactiveAt?.toIso8601String(),
    'archivedAt': archivedAt?.toIso8601String(),
    'deleteEligibleAt': deleteEligibleAt?.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      schoolId: json['schoolId'],
      name: json['name'],
      rollNo: json['rollNo'],
      classNumber: json['classNumber'],
      photoUrl: json['photoUrl'],
      isStruckOff: json['isStruckOff'] ?? false,
      canStudentLogin: json['canStudentLogin'] ?? true,
      canParentView: json['canParentView'] ?? true,
      email: json['email'],
      isPasswordCreated: json['isPasswordCreated'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      parentEmail: json['parentEmail'] ?? '',
      parentCnic: json['parentCnic'] ?? '',
      contactNumber: json['contactNumber'],
      address: json['address'],
      admissionDate: json['admissionDate'] != null
          ? DateTime.parse(json['admissionDate'])
          : null,
      lifecycleStatus: StudentLifecycleStatus.values.firstWhere(
        (e) => e.name == json['lifecycleStatus'],
        orElse: () => StudentLifecycleStatus.active,
      ),
      inactiveAt: json['inactiveAt'] != null
          ? DateTime.parse(json['inactiveAt'])
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'])
          : null,
      deleteEligibleAt: json['deleteEligibleAt'] != null
          ? DateTime.parse(json['deleteEligibleAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }
}
