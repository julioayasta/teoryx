import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/presentation/controllers/course_repository_scope.dart';
import '../../../../features/progress/data/repositories/mock_progress_repository.dart';
import '../../../../features/progress/domain/entities/student_progress.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../controllers/student_repository_scope.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const _progressRepository = MockProgressRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final student = StudentRepositoryScope.of(context).getCurrentStudent();
    final enrolledCourses = CourseRepositoryScope.of(
      context,
    ).getEnrolledCourses(languageCode);
    final currentProgress = _progressRepository.getCurrentProgress(
      languageCode,
    );
    final recommendation = _ProgressRecommendation.from(
      context,
      currentProgress,
    );

    return AppScaffold(
      breadcrumbs: [AppBreadcrumb(label: context.l10n.dashboardTitle)],
      leading: IconButton(
        tooltip: context.l10n.backToLogin,
        onPressed: () => context.goNamed(RouteNames.mockLogin),
        icon: const Icon(Icons.arrow_back),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.studentGreeting(student.firstName),
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: context.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(context.l10n.studentMetadataPlaceholder),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.continueStudyingTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (enrolledCourses.isEmpty)
            Text(context.l10n.noStartedCourses)
          else
            for (final course in enrolledCourses)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              course.title,
                              style: context.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recommendation.heading,
                        style: context.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(recommendation.primaryLessonTitle),
                      if (recommendation.previousLessonText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.previousLessonLabel,
                          style: context.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(recommendation.previousLessonText!),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.progressLabel,
                        style: context.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(currentProgress.lessonProgressLabel),
                      const SizedBox(height: 12),
                      _ProgressDetails(progress: currentProgress),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.goNamed(
                          recommendation.routeName,
                          pathParameters: {
                            'courseId': currentProgress.courseId,
                            'lessonId': recommendation.targetLessonId,
                          },
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(recommendation.actionLabel),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.goNamed(RouteNames.progressDashboard),
                        icon: const Icon(Icons.insights_outlined),
                        label: Text(context.l10n.viewProgressAction),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('choose-new-course-button'),
            onPressed: () => context.goNamed(RouteNames.gradeSelection),
            icon: const Icon(Icons.school_outlined),
            label: Text(context.l10n.newCourseFromCatalog),
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.studentMetricsTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricPlaceholder(
                title: context.l10n.weeklyGoalMetric,
                icon: Icons.flag_outlined,
              ),
              _MetricPlaceholder(
                title: context.l10n.learningStreakMetric,
                icon: Icons.local_fire_department_outlined,
              ),
              _MetricPlaceholder(
                title: context.l10n.masteryScoreMetric,
                icon: Icons.insights_outlined,
              ),
              _MetricPlaceholder(
                title: context.l10n.lessonsCompletedMetric,
                icon: Icons.task_alt_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRecommendation {
  const _ProgressRecommendation({
    required this.heading,
    required this.primaryLessonTitle,
    required this.targetLessonId,
    required this.routeName,
    required this.actionLabel,
    this.previousLessonText,
  });

  final String heading;
  final String primaryLessonTitle;
  final String targetLessonId;
  final String routeName;
  final String actionLabel;
  final String? previousLessonText;

  factory _ProgressRecommendation.from(
    BuildContext context,
    StudentProgress progress,
  ) {
    return switch (progress.currentLessonStatus) {
      LessonProgressStatus.studying => _ProgressRecommendation(
        heading: context.l10n.continueLessonLabel,
        primaryLessonTitle: progress.currentLessonTitle,
        targetLessonId: progress.currentLessonId,
        routeName: RouteNames.lessonDetail,
        actionLabel: context.l10n.continueLearningAction,
      ),
      LessonProgressStatus.assessmentStarted => _ProgressRecommendation(
        heading: context.l10n.continueAssessmentLabel,
        primaryLessonTitle: progress.currentLessonTitle,
        targetLessonId: progress.currentLessonId,
        routeName: RouteNames.assessment,
        actionLabel: context.l10n.continueAssessmentAction,
      ),
      LessonProgressStatus.assessmentCompleted ||
      LessonProgressStatus.readyForNextLesson => _ProgressRecommendation(
        heading: context.l10n.recommendedNextLabel,
        primaryLessonTitle: progress.nextLessonTitle,
        targetLessonId: progress.nextLessonId,
        routeName: RouteNames.lessonDetail,
        actionLabel: context.l10n.continueWithNextLessonAction,
        previousLessonText: context.l10n.previousLessonCompleted(
          progress.currentLessonTitle,
        ),
      ),
    };
  }
}

class _ProgressDetails extends StatelessWidget {
  const _ProgressDetails({required this.progress});

  final StudentProgress progress;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ProgressChip(
          label: context.l10n.masteryStateLabel,
          value: _masteryLabel(context, progress.masteryLevel),
        ),
        if (progress.lastAssessmentScorePercentage != null)
          _ProgressChip(
            label: context.l10n.lastAssessmentScoreLabel,
            value: context.l10n.autoGradedScoreValue(
              progress.lastAssessmentScorePercentage!,
            ),
          ),
        if (progress.hasPendingReview)
          _ProgressChip(
            label: context.l10n.pendingReviewNotice,
            value: context.l10n.pendingReviewCountValue(
              progress.pendingReviewCount,
            ),
          ),
      ],
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

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $value'),
      side: BorderSide(color: context.colorScheme.outlineVariant),
    );
  }
}

class _MetricPlaceholder extends StatelessWidget {
  const _MetricPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
