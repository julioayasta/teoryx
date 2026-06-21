import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firestore_user_profile_data_source.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirestoreUserProfileDataSource? userProfileDataSource,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _userProfileDataSource =
           userProfileDataSource ?? FirestoreUserProfileDataSource();

  final FirebaseAuth _firebaseAuth;
  final FirestoreUserProfileDataSource _userProfileDataSource;

  @override
  Stream<AuthenticatedUser?> authStateChanges() async* {
    await for (final firebaseUser in _firebaseAuth.authStateChanges()) {
      if (firebaseUser == null) {
        yield null;
        continue;
      }

      yield await _authenticatedUserFromFirebaseUser(firebaseUser);
    }
  }

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw StateError('Firebase Auth did not return a signed-in user.');
    }

    return _authenticatedUserFromFirebaseUser(firebaseUser);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<AuthenticatedUser> _authenticatedUserFromFirebaseUser(
    User firebaseUser,
  ) async {
    final profile = await _userProfileDataSource.getUserProfile(
      firebaseUser.uid,
    );

    if (profile == null) {
      throw StateError('No Firestore user profile exists for this account.');
    }

    if (profile.schoolId.isEmpty) {
      throw StateError('The signed-in user profile is missing schoolId.');
    }

    return profile.toEntity();
  }
}
