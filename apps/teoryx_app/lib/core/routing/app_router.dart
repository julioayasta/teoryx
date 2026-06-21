import 'package:go_router/go_router.dart';

import '../../features/lesson/presentation/screens/lesson_detail_screen.dart';
import '../../features/lesson/presentation/screens/lesson_list_screen.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/student/presentation/screens/welcome_screen.dart';
import '../../features/tutor/presentation/screens/tutor_chat_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/student',
        name: RouteNames.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/lessons',
        name: RouteNames.lessonList,
        builder: (context, state) => const LessonListScreen(),
      ),
      GoRoute(
        path: '/lessons/:lessonId',
        name: RouteNames.lessonDetail,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonDetailScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/lessons/:lessonId/tutor',
        name: RouteNames.tutorChat,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return TutorChatScreen(lessonId: lessonId);
        },
      ),
    ],
  );
}
