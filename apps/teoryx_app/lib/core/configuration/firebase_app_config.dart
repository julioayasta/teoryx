class FirebaseAppConfig {
  const FirebaseAppConfig._();

  static const isEnabled = bool.fromEnvironment('TEORYX_FIREBASE_ENABLED');
}
