import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_lesson_repository.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({
    required this.lessonId,
    super.key,
  });

  final String lessonId;

  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final lesson = _lessonRepository.getLessonById(lessonId);

    return AppScaffold(
      title: lesson.title,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            lesson.title,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            lesson.standardCode,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _LessonSection(
            title: context.l10n.bigIdeaLabel,
            body: lesson.bigIdea,
            icon: Icons.lightbulb_outline,
          ),
          _LessonSection(
            title: context.l10n.essentialQuestionLabel,
            body: lesson.essentialQuestion,
            icon: Icons.help_outline,
          ),
          _LessonSection(
            title: context.l10n.learningObjectiveLabel,
            body: lesson.learningObjective.statement,
            icon: Icons.flag_outlined,
          ),
          _LessonSection(
            title: context.l10n.lessonContentLabel,
            body: lesson.lessonContent,
            icon: Icons.article_outlined,
          ),
          _LessonSection(
            title: context.l10n.guidedPracticeLabel,
            body: lesson.guidedPractice,
            icon: Icons.groups_outlined,
          ),
          _LessonSection(
            title: context.l10n.independentPracticeLabel,
            body: lesson.independentPractice,
            icon: Icons.edit_note_outlined,
          ),
          _LessonSection(
            title: context.l10n.summaryLabel,
            body: lesson.summary,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.goNamed(
              RouteNames.tutorChat,
              pathParameters: {'lessonId': lesson.id},
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(context.l10n.askTutor),
          ),
        ],
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: context.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
