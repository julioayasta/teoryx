class FirebaseAppConfig {
  const FirebaseAppConfig._();

  static const isEnabled = bool.fromEnvironment('TEORYX_FIREBASE_ENABLED');
  static const hasGeneratedConfiguration = bool.fromEnvironment(
    'TEORYX_FIREBASE_CONFIGURED',
  );
  static const initializationTimeout = Duration(seconds: 5);
}
