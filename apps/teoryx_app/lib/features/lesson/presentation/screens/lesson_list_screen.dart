import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_specification.dart';
import '../controllers/course_repository_scope.dart';
import '../controllers/lesson_repository_scope.dart';
import '../controllers/lesson_specification_repository_scope.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final lessonRepository = LessonRepositoryScope.of(context);
    final lessons = lessonRepository.getLessonsForCourse(
      courseId,
      languageCode,
    );
    final lessonSpecificationRepository = LessonSpecificationRepositoryScope.of(
      context,
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
          FutureBuilder<List<LessonSpecification>>(
            future: lessonSpecificationRepository
                .getLessonSpecificationsForCourse(courseId, languageCode),
            builder: (context, snapshot) {
              final specs = snapshot.data ?? const <LessonSpecification>[];

              if (specs.isNotEmpty) {
                return Column(
                  children: [
                    for (final spec in specs) ...[
                      _LessonSpecificationTile(courseId: courseId, spec: spec),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              if (lessons.isEmpty) {
                return Text(context.l10n.noLessonsForCourse);
              }

              return Column(
                children: [
                  for (final lesson in lessons) ...[
                    _LessonTile(courseId: courseId, lesson: lesson),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.courseId, required this.lesson});

  final String courseId;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}

class _LessonSpecificationTile extends StatelessWidget {
  const _LessonSpecificationTile({required this.courseId, required this.spec});

  final String courseId;
  final LessonSpecification spec;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      leading: Icon(
        Icons.auto_stories_outlined,
        color: context.colorScheme.primary,
      ),
      title: Text(spec.title),
      subtitle: Text('${spec.estimatedDuration} - ${spec.difficultyLevel}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.goNamed(
        RouteNames.lessonDetail,
        pathParameters: {'courseId': courseId, 'lessonId': spec.id},
      ),
    );
  }
}
