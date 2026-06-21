import 'package:go_router/go_router.dart';

import '../../features/lesson/presentation/screens/lesson_detail_screen.dart';
import '../../features/lesson/presentation/screens/lesson_list_screen.dart';
import '../../features/lesson/presentation/screens/course_selection_screen.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/student/presentation/screens/welcome_screen.dart';
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
        path: '/courses',
        name: RouteNames.courseSelection,
        builder: (context, state) => const CourseSelectionScreen(),
      ),
      GoRoute(
        path: '/courses/:courseId/lessons',
        name: RouteNames.lessonList,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return LessonListScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId',
        name: RouteNames.lessonDetail,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return LessonDetailScreen(courseId: courseId, lessonId: lessonId);
        },
      ),
    ],
  );
}
