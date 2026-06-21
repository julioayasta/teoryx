import 'environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.supportsK12Architecture,
  });

  const AppConfig.development()
    : environment = Environment.development,
      supportsK12Architecture = true;

  final Environment environment;
  final bool supportsK12Architecture;
}
