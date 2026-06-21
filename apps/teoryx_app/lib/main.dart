import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await initializeAppDependencies();

  runApp(buildTeoryXApp(dependencies: dependencies));
}
