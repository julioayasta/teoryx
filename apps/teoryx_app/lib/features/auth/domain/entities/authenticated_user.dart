import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_role.dart';

class AuthenticatedUser extends Equatable {
  const AuthenticatedUser({
    required this.id,
    required this.schoolId,
    required this.email,
    required this.role,
  });

  final String id;
  final String schoolId;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, schoolId, email, role];
}
