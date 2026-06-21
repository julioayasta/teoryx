import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_progress_repository.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/entities/student_progress.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  static const _progressRepository = MockProgressRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final courseProgress = _progressRepository.getCourseProgress(languageCode);

    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(label: context.l10n.progressDashboardTitle),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToDashboard,
        onPressed: () => context.goNamed(RouteNames.studentDashboard),
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
          Text(
            context.l10n.progressDashboardTitle,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _CourseProgressSummary(courseProgress: courseProgress),
          const SizedBox(height: 16),
          _MasterySummary(lessons: courseProgress.lessons),
          const SizedBox(height: 16),
          _AssessmentSummary(summary: courseProgress.latestAssessmentSummary),
          const SizedBox(height: 16),
          _RecommendationSection(courseProgress: courseProgress),
        ],
      ),
    );
  }
}

class _CourseProgressSummary extends StatelessWidget {
  const _CourseProgressSummary({required this.courseProgress});

  final CourseProgress courseProgress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseProgress.courseTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _LabelValueRow(
              label: context.l10n.progressLabel,
              value: context.l10n.lessonsCompletedOfTotal(
                courseProgress.completedLessonCount,
                courseProgress.totalLessonCount,
              ),
            ),
            const SizedBox(height: 8),
            _LabelValueRow(
              label: context.l10n.currentRecommendationLabel,
              value: courseProgress.currentRecommendation,
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterySummary extends StatelessWidget {
  const _MasterySummary({required this.lessons});

  final List<LessonProgress> lessons;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.masterySummaryTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final lesson in lessons)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _LabelValueRow(
                  label: lesson.lessonTitle,
                  value: _masteryLabel(context, lesson.masteryLevel),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _masteryLabel(BuildContext context, MasteryLevel masteryLevel) {
    return switch (masteryLevel) {
      MasteryLevel.notStarted => context.l10n.masteryNotStarted,
      MasteryLevel.inProgress => context.l10n.masteryInProgress,
      MasteryLevel.developing => context.l10n.masteryDeveloping,
      MasteryLevel.proficient => context.l10n.masteryProficient,
      MasteryLevel.mastered => context.l10n.masteryMastered,
    };
  }
}

class _AssessmentSummary extends StatelessWidget {
  const _AssessmentSummary({required this.summary});

  final AssessmentProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.assessmentSummaryTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(summary.lessonTitle, style: context.textTheme.titleSmall),
            const SizedBox(height: 12),
            _LabelValueRow(
              label: context.l10n.autoGradedScore,
              value: '${summary.autoGradedScorePercentage}%',
            ),
            const SizedBox(height: 8),
            _LabelValueRow(
              label: context.l10n.finalScore,
              value: summary.finalScoreLabel,
            ),
            const SizedBox(height: 8),
            _LabelValueRow(
              label: context.l10n.pendingReviewItems,
              value: '${summary.pendingReviewCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.courseProgress});

  final CourseProgress courseProgress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseProgress.recommendation.title,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(courseProgress.recommendation.message),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.goNamed(
                RouteNames.lessonDetail,
                pathParameters: {
                  'courseId': courseProgress.courseId,
                  'lessonId': courseProgress.recommendation.recommendedLessonId,
                },
              ),
              icon: const Icon(Icons.arrow_forward),
              label: Text(courseProgress.recommendation.recommendedActionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: context.textTheme.labelLarge),
        ),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: Text(value)),
      ],
    );
  }
}
