import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/data/repositories/mock_course_repository.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_student_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const _studentRepository = MockStudentRepository();
  static const _courseRepository = MockCourseRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final student = _studentRepository.getCurrentStudent();
    final enrolledCourses = _courseRepository.getEnrolledCourses(languageCode);

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
                        context.l10n.currentLessonLabel,
                        style: context.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(context.l10n.currentLessonComparingFractions),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.progressLabel,
                        style: context.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(context.l10n.lessonProgressTwoOfEight),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.goNamed(
                          RouteNames.lessonDetail,
                          pathParameters: {
                            'courseId': course.id,
                            'lessonId': 'comparing-fractions',
                          },
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(context.l10n.continueLearningAction),
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
