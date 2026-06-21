import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_lesson_repository.dart';
import '../../domain/entities/lesson_step.dart';

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
    final steps = [...lesson.steps]..sort((a, b) => a.order.compareTo(b.order));

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
          Text(
            context.l10n.guidedLessonTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final step in steps) _LessonStepCard(step: step),
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

class _LessonStepCard extends StatelessWidget {
  const _LessonStepCard({required this.step});

  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.primaryContainer,
                  foregroundColor: context.colorScheme.onPrimaryContainer,
                  child: Text('${step.order}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelFor(context, step.type),
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.title,
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Icon(_iconFor(step.type), color: context.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            if (step.type == LessonStepType.imagePlaceholder)
              _ImagePlaceholder(step: step)
            else
              Text(step.body),
            if (step.prompt != null) ...[
              const SizedBox(height: 12),
              _Callout(
                title: context.l10n.lessonStepPromptLabel,
                body: step.prompt!,
                icon: Icons.record_voice_over_outlined,
              ),
            ],
            if (step.expectedAnswer != null) ...[
              const SizedBox(height: 12),
              _Callout(
                title: context.l10n.lessonStepExpectedAnswerLabel,
                body: step.expectedAnswer!,
                icon: Icons.task_alt_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, LessonStepType type) {
    return switch (type) {
      LessonStepType.story => context.l10n.lessonStepTypeStory,
      LessonStepType.imagePlaceholder => context.l10n.lessonStepTypeImagePlaceholder,
      LessonStepType.explanation => context.l10n.lessonStepTypeExplanation,
      LessonStepType.question => context.l10n.lessonStepTypeQuestion,
      LessonStepType.practice => context.l10n.lessonStepTypePractice,
      LessonStepType.summary => context.l10n.lessonStepTypeSummary,
    };
  }

  IconData _iconFor(LessonStepType type) {
    return switch (type) {
      LessonStepType.story => Icons.auto_stories_outlined,
      LessonStepType.imagePlaceholder => Icons.image_outlined,
      LessonStepType.explanation => Icons.psychology_alt_outlined,
      LessonStepType.question => Icons.quiz_outlined,
      LessonStepType.practice => Icons.edit_note_outlined,
      LessonStepType.summary => Icons.summarize_outlined,
    };
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.step});

  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: context.colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.image_search_outlined, color: context.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(step.imageDescription ?? step.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colorScheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
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
