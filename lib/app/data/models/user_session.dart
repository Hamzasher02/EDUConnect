import '../enums/app_enums.dart';

class UserSession {
  final String userId;
  final UserRole role;
  final String? schoolId; // Required for School Admin & Teacher
  final String? email; // For display
  final String? name; // For display

  UserSession({
    required this.userId,
    required this.role,
    this.schoolId,
    this.email,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role.index, // Store as int for simplicity
      'schoolId': schoolId,
      'email': email,
      'name': name,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'],
      role: UserRole.values[json['role']],
      schoolId: json['schoolId'],
      email: json['email'],
      name: json['name'],
    );
  }
}
