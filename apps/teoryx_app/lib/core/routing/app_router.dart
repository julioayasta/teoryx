import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/screens/assessment_results_screen.dart';
import '../../features/assessment/presentation/screens/assessment_screen.dart';
import '../../features/lesson/presentation/screens/lesson_detail_screen.dart';
import '../../features/lesson/presentation/screens/lesson_list_screen.dart';
import '../../features/lesson/presentation/screens/course_list_screen.dart';
import '../../features/lesson/presentation/screens/grade_selection_screen.dart';
import '../../features/progress/presentation/screens/progress_dashboard_screen.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/student/presentation/screens/mock_login_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.mockLogin,
        builder: (context, state) => const MockLoginScreen(),
      ),
      GoRoute(
        path: '/student',
        name: RouteNames.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student/progress',
        name: RouteNames.progressDashboard,
        builder: (context, state) => const ProgressDashboardScreen(),
      ),
      GoRoute(
        path: '/catalog/grades',
        name: RouteNames.gradeSelection,
        builder: (context, state) => const GradeSelectionScreen(),
      ),
      GoRoute(
        path: '/catalog/grades/:gradeLevelId/courses',
        name: RouteNames.courseList,
        builder: (context, state) {
          final gradeLevelId = state.pathParameters['gradeLevelId']!;
          return CourseListScreen(gradeLevelId: gradeLevelId);
        },
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
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId/assessment',
        name: RouteNames.assessment,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return AssessmentScreen(courseId: courseId, lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId/assessment/results',
        name: RouteNames.assessmentResults,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return AssessmentResultsScreen(
            courseId: courseId,
            lessonId: lessonId,
          );
        },
      ),
    ],
  );
}
