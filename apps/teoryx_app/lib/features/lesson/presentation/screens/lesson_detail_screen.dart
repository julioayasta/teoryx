import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../features/tutor/presentation/widgets/tutor_chat_panel.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../controllers/course_repository_scope.dart';
import '../controllers/lesson_repository_scope.dart';
import '../widgets/guided_lesson_step_card.dart';
import '../widgets/learning_details_section.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final lesson = LessonRepositoryScope.of(
      context,
    ).getLessonById(lessonId, languageCode);
    final course = CourseRepositoryScope.of(
      context,
    ).getCourseById(courseId, languageCode);
    final steps = [...lesson.steps]..sort((a, b) => a.order.compareTo(b.order));

    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(
          label: course.title,
          onTap: () => context.goNamed(
            RouteNames.lessonList,
            pathParameters: {'courseId': courseId},
          ),
        ),
        AppBreadcrumb(label: lesson.title),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToLessons,
        onPressed: () => context.goNamed(
          RouteNames.lessonList,
          pathParameters: {'courseId': courseId},
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          tooltip: context.l10n.dashboardTitle,
          onPressed: () => context.goNamed(RouteNames.studentDashboard),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTutorPanel(context, lesson.id),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(context.l10n.askTutor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(lesson.title, style: context.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.guidedLessonIntro,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          for (final step in steps) GuidedLessonStepCard(step: step),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.goNamed(
              RouteNames.assessment,
              pathParameters: {'courseId': courseId, 'lessonId': lesson.id},
            ),
            icon: const Icon(Icons.assignment_outlined),
            label: Text(context.l10n.startAssessment),
          ),
          const SizedBox(height: 12),
          LearningDetailsSection(lesson: lesson),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showTutorPanel(BuildContext context, String lessonId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TutorChatPanel(lessonId: lessonId),
    );
  }
}
