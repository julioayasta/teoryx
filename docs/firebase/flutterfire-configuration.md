# FlutterFire Configuration

Firebase mode is disabled by default. The app runs with mock repositories unless
started with:

```sh
flutter run --dart-define=TEORYX_FIREBASE_ENABLED=true
```

If Firebase is requested before FlutterFire configuration exists, TeoryX falls
back to mock auth and logs a clear bootstrap message. After configuration is
generated and verified for the target platform, run with:

```sh
flutter run \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true
```

Before enabling Firebase mode for a platform, configure FlutterFire:

```sh
flutterfire configure
```

Expected generated or updated files include:

- `apps/teoryx_app/lib/firebase_options.dart`
- platform Firebase configuration for selected targets
- generated platform plugin registration files

For Linux desktop, verify that the selected Firebase packages support the Linux
target and that the generated Linux plugin registrant includes Firebase plugins.
If configuration or platform support is missing, TeoryX falls back to mock auth
and logs a clear Firebase bootstrap message.
