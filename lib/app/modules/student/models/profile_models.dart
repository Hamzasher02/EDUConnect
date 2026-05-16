class StudentProfileModel {
  final String studentId;
  final String name;
  final String rollNumber;
  final String className;
  final String section;
  final String email;
  final String phone;
  final String guardianName;
  final String guardianPhone;
  final String? profilePictureUrl;
  final String status; // Active / Inactive

  StudentProfileModel({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.section,
    required this.email,
    required this.phone,
    required this.guardianName,
    required this.guardianPhone,
    this.profilePictureUrl,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'name': name,
    'rollNumber': rollNumber,
    'className': className,
    'section': section,
    'email': email,
    'phone': phone,
    'guardianName': guardianName,
    'guardianPhone': guardianPhone,
    'profilePictureUrl': profilePictureUrl,
    'status': status,
  };

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      studentId: json['studentId'],
      name: json['name'],
      rollNumber: json['rollNumber'],
      className: json['className'],
      section: json['section'],
      email: json['email'],
      phone: json['phone'],
      guardianName: json['guardianName'],
      guardianPhone: json['guardianPhone'],
      profilePictureUrl: json['profilePictureUrl'],
      status: json['status'],
    );
  }

  StudentProfileModel copyWith({
    String? email,
    String? phone,
    String? profilePictureUrl,
  }) {
    return StudentProfileModel(
      studentId: studentId,
      name: name,
      rollNumber: rollNumber,
      className: className,
      section: section,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      guardianName: guardianName,
      guardianPhone: guardianPhone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      status: status,
    );
  }
}
