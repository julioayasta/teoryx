class FirebaseAppConfig {
  const FirebaseAppConfig._();

  static const isEnabled = bool.fromEnvironment('TEORYX_FIREBASE_ENABLED');
  static const hasGeneratedConfiguration = bool.fromEnvironment(
    'TEORYX_FIREBASE_CONFIGURED',
  );
  static const useEmulators = bool.fromEnvironment(
    'TEORYX_USE_FIREBASE_EMULATORS',
  );
  static const emulatorHost = String.fromEnvironment(
    'TEORYX_FIREBASE_EMULATOR_HOST',
    defaultValue: 'localhost',
  );
  static const firestoreEmulatorPort = int.fromEnvironment(
    'TEORYX_FIRESTORE_EMULATOR_PORT',
    defaultValue: 8080,
  );
  static const functionsEmulatorPort = int.fromEnvironment(
    'TEORYX_FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );
  static const authEmulatorPort = int.fromEnvironment(
    'TEORYX_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );
  static const initializationTimeout = Duration(seconds: 5);
}
