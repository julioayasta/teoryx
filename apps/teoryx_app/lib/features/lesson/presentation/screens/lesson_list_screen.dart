import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_lesson_repository.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({required this.courseId, super.key});

  final String courseId;

  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final lessons = _lessonRepository.getLessonsForCourse(courseId);

    return AppScaffold(
      title: context.l10n.lessonListTitle,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            onPressed: () => context.goNamed(RouteNames.courseSelection),
            icon: const Icon(Icons.arrow_back),
            label: Text(context.l10n.backToCourses),
          ),
          const SizedBox(height: 20),
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
