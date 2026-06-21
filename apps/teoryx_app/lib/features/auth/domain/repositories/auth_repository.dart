import '../entities/authenticated_user.dart';

abstract class AuthRepository {
  Stream<AuthenticatedUser?> authStateChanges();

  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
