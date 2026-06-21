import '../../../../shared/models/user_role.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  AuthenticatedUser? _currentUser;

  @override
  Stream<AuthenticatedUser?> authStateChanges() async* {
    yield _currentUser;
  }

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = AuthenticatedUser(
      id: 'user-student-001',
      schoolId: 'school-demo',
      email: email.isEmpty ? 'sofia@student.teoryx.local' : email,
      role: UserRole.student,
    );

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
