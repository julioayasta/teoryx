import 'package:flutter/material.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/entities/lesson.dart';

class LearningDetailsSection extends StatelessWidget {
  const LearningDetailsSection({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: context.colorScheme.primary),
        title: Text(context.l10n.learningDetailsTitle),
        subtitle: Text(lesson.standardCode),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _LearningDetail(
            title: context.l10n.bigIdeaLabel,
            body: lesson.bigIdea,
          ),
          _LearningDetail(
            title: context.l10n.essentialQuestionLabel,
            body: lesson.essentialQuestion,
          ),
          _LearningDetail(
            title: context.l10n.learningObjectiveLabel,
            body: lesson.learningObjective.statement,
          ),
          _LearningDetail(
            title: context.l10n.lessonContentLabel,
            body: lesson.lessonContent,
          ),
          _LearningDetail(
            title: context.l10n.guidedPracticeLabel,
            body: lesson.guidedPractice,
          ),
          _LearningDetail(
            title: context.l10n.independentPracticeLabel,
            body: lesson.independentPractice,
          ),
          _LearningDetail(
            title: context.l10n.summaryLabel,
            body: lesson.summary,
          ),
        ],
      ),
    );
  }
}

class _LearningDetail extends StatelessWidget {
  const _LearningDetail({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}
