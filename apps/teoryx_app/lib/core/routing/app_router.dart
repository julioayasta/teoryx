import 'package:go_router/go_router.dart';

import '../../shared/widgets/foundation_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.foundation,
        builder: (context, state) => const FoundationScreen(),
      ),
    ],
  );
}
