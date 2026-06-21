import '../../../../shared/models/user_role.dart';
import '../../domain/entities/authenticated_user.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.schoolId,
    required this.email,
    required this.role,
    required this.status,
  });

  final String id;
  final String schoolId;
  final String email;
  final UserRole role;
  final String status;

  AuthenticatedUser toEntity() {
    return AuthenticatedUser(
      id: id,
      schoolId: schoolId,
      email: email,
      role: role,
    );
  }

  static UserProfileModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return UserProfileModel(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: userRoleFromFirestore(data['role'] as String?),
      status: data['status'] as String? ?? 'active',
    );
  }
}

UserRole userRoleFromFirestore(String? value) {
  return switch (value) {
    'super_admin' => UserRole.superAdmin,
    'school_admin' => UserRole.schoolAdmin,
    'parent' => UserRole.parent,
    'student' || _ => UserRole.student,
  };
}

String userRoleToFirestore(UserRole role) {
  return switch (role) {
    UserRole.superAdmin => 'super_admin',
    UserRole.schoolAdmin => 'school_admin',
    UserRole.parent => 'parent',
    UserRole.student => 'student',
  };
}
