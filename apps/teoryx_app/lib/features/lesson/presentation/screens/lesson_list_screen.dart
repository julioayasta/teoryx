import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_lesson_repository.dart';
import '../controllers/course_repository_scope.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({required this.courseId, super.key});

  final String courseId;

  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final lessons = _lessonRepository.getLessonsForCourse(
      courseId,
      languageCode,
    );
    final course = CourseRepositoryScope.of(
      context,
    ).getCourseById(courseId, languageCode);

    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(label: course.title),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToCourses,
        onPressed: () {
          final gradeLevelId = courseId.startsWith('grade-5')
              ? 'grade-5'
              : 'grade-4';
          context.goNamed(
            RouteNames.courseList,
            pathParameters: {'gradeLevelId': gradeLevelId},
          );
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          tooltip: context.l10n.dashboardTitle,
          onPressed: () => context.goNamed(RouteNames.studentDashboard),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (lessons.isEmpty)
            Text(context.l10n.noLessonsForCourse)
          else
            for (final lesson in lessons) ...[
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: context.colorScheme.outlineVariant),
                ),
                leading: Icon(
                  Icons.auto_stories_outlined,
                  color: context.colorScheme.primary,
                ),
                title: Text(lesson.title),
                subtitle: Text(lesson.learningObjective.statement),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.goNamed(
                  RouteNames.lessonDetail,
                  pathParameters: {'courseId': courseId, 'lessonId': lesson.id},
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
