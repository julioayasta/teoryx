import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../features/tutor/presentation/widgets/tutor_chat_panel.dart';
import '../../data/repositories/mock_lesson_repository.dart';
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

  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final lesson = _lessonRepository.getLessonById(lessonId);
    final steps = [...lesson.steps]..sort((a, b) => a.order.compareTo(b.order));

    return AppScaffold(
      title: lesson.title,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTutorPanel(context, lesson.id),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(context.l10n.askTutor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            onPressed: () => context.goNamed(
              RouteNames.lessonList,
              pathParameters: {'courseId': courseId},
            ),
            icon: const Icon(Icons.arrow_back),
            label: Text(context.l10n.backToLessons),
          ),
          const SizedBox(height: 20),
          Text(lesson.title, style: context.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.guidedLessonIntro,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          for (final step in steps) GuidedLessonStepCard(step: step),
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
