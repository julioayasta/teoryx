import 'package:flutter/material.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/entities/lesson_step.dart';

class GuidedLessonStepCard extends StatelessWidget {
  const GuidedLessonStepCard({required this.step, super.key});

  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    final style = _StepVisualStyle.forType(context, step.type);

    return Card(
      color: style.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: style.badgeColor,
                  foregroundColor: style.onBadgeColor,
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
                          color: style.labelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(step.title, style: context.textTheme.titleMedium),
                    ],
                  ),
                ),
                Icon(style.icon, color: style.labelColor),
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
      LessonStepType.imagePlaceholder =>
        context.l10n.lessonStepTypeImagePlaceholder,
      LessonStepType.explanation => context.l10n.lessonStepTypeExplanation,
      LessonStepType.question => context.l10n.lessonStepTypeQuestion,
      LessonStepType.practice => context.l10n.lessonStepTypePractice,
      LessonStepType.summary => context.l10n.lessonStepTypeSummary,
    };
  }
}

class _StepVisualStyle {
  const _StepVisualStyle({
    required this.backgroundColor,
    required this.badgeColor,
    required this.onBadgeColor,
    required this.labelColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color badgeColor;
  final Color onBadgeColor;
  final Color labelColor;
  final IconData icon;

  factory _StepVisualStyle.forType(BuildContext context, LessonStepType type) {
    final colorScheme = context.colorScheme;

    return switch (type) {
      LessonStepType.story => _StepVisualStyle(
        backgroundColor: colorScheme.surface,
        badgeColor: colorScheme.primaryContainer,
        onBadgeColor: colorScheme.onPrimaryContainer,
        labelColor: colorScheme.primary,
        icon: Icons.auto_stories_outlined,
      ),
      LessonStepType.imagePlaceholder => _StepVisualStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        badgeColor: colorScheme.secondaryContainer,
        onBadgeColor: colorScheme.onSecondaryContainer,
        labelColor: colorScheme.secondary,
        icon: Icons.image_outlined,
      ),
      LessonStepType.explanation => _StepVisualStyle(
        backgroundColor: colorScheme.surface,
        badgeColor: colorScheme.tertiaryContainer,
        onBadgeColor: colorScheme.onTertiaryContainer,
        labelColor: colorScheme.tertiary,
        icon: Icons.psychology_alt_outlined,
      ),
      LessonStepType.question => _StepVisualStyle(
        backgroundColor: colorScheme.surface,
        badgeColor: colorScheme.primaryContainer,
        onBadgeColor: colorScheme.onPrimaryContainer,
        labelColor: colorScheme.primary,
        icon: Icons.quiz_outlined,
      ),
      LessonStepType.practice => _StepVisualStyle(
        backgroundColor: colorScheme.surface,
        badgeColor: colorScheme.secondaryContainer,
        onBadgeColor: colorScheme.onSecondaryContainer,
        labelColor: colorScheme.secondary,
        icon: Icons.edit_note_outlined,
      ),
      LessonStepType.summary => _StepVisualStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        badgeColor: colorScheme.tertiaryContainer,
        onBadgeColor: colorScheme.onTertiaryContainer,
        labelColor: colorScheme.tertiary,
        icon: Icons.summarize_outlined,
      ),
    };
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.step});

  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: context.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_search_outlined,
                color: context.colorScheme.primary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                step.imageDescription ?? step.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.title, required this.body, required this.icon});

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
