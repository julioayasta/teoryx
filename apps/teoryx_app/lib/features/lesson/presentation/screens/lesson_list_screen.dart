import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_lesson_repository.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key});

  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final lessons = _lessonRepository.getAvailableLessons();

    return AppScaffold(
      title: context.l10n.lessonListTitle,
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final lesson = lessons[index];

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
              pathParameters: {'lessonId': lesson.id},
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: lessons.length,
      ),
    );
  }
}
