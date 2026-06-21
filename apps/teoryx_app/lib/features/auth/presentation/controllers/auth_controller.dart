import 'package:flutter/foundation.dart';

import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AuthenticatedUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthenticatedUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentUser != null;

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _currentUser = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on Object catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
