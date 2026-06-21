class FirebaseBootstrapStatus {
  const FirebaseBootstrapStatus._({
    required this.isFirebaseRequested,
    required this.isFirebaseAvailable,
    this.message,
  });

  const FirebaseBootstrapStatus.mockMode()
    : this._(isFirebaseRequested: false, isFirebaseAvailable: false);

  const FirebaseBootstrapStatus.available()
    : this._(
        isFirebaseRequested: true,
        isFirebaseAvailable: true,
        message: 'Firebase initialized successfully.',
      );

  const FirebaseBootstrapStatus.fallback(String message)
    : this._(
        isFirebaseRequested: true,
        isFirebaseAvailable: false,
        message: message,
      );

  final bool isFirebaseRequested;
  final bool isFirebaseAvailable;
  final String? message;

  bool get isFallbackActive => isFirebaseRequested && !isFirebaseAvailable;
}
