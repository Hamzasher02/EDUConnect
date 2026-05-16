class TokenNotFoundException implements Exception {
  final String message;
  TokenNotFoundException([this.message = 'Invitation token not found.']);
  @override
  String toString() => message;
}

class TokenAlreadyUsedException implements Exception {
  final String message;
  TokenAlreadyUsedException([
    this.message = 'This invitation has already been used.',
  ]);
  @override
  String toString() => message;
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Invitation link has expired.']);
  @override
  String toString() => message;
}

class InvalidRoleException implements Exception {
  final String message;
  InvalidRoleException([this.message = 'Invalid role for this invitation.']);
  @override
  String toString() => message;
}

class WeakPasswordException implements Exception {
  final String message;
  WeakPasswordException([this.message = 'Password is too weak.']);
  @override
  String toString() => message;
}

class TeacherNotFoundException implements Exception {
  final String message;
  TeacherNotFoundException([this.message = 'Teacher profile not found.']);
  @override
  String toString() => message;
}
