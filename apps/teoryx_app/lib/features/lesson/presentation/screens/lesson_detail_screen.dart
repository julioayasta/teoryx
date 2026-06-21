import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../features/tutor/presentation/widgets/tutor_chat_panel.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../domain/entities/content_generation_result.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_specification.dart';
import '../controllers/content_generation_repository_scope.dart';
import '../controllers/course_repository_scope.dart';
import '../controllers/lesson_repository_scope.dart';
import '../controllers/lesson_specification_repository_scope.dart';
import '../widgets/guided_lesson_step_card.dart';
import '../widgets/learning_details_section.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Future<_LessonDetailState> _lessonFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lessonFuture = _resolveLesson();
  }

  Future<_LessonDetailState> _resolveLesson() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final lessonRepository = LessonRepositoryScope.of(context);
    final lessonSpecificationRepository = LessonSpecificationRepositoryScope.of(
      context,
    );

    final specification = await lessonSpecificationRepository
        .getLessonSpecificationById(widget.lessonId, languageCode);

    if (specification == null) {
      final lesson = await lessonRepository.getPublishedLessonById(
        widget.lessonId,
        languageCode,
      );

      if (lesson != null) {
        return _LessonDetailState.ready(lesson);
      }

      return _LessonDetailState.ready(
        lessonRepository.getLessonById(widget.lessonId, languageCode),
      );
    }

    final publishedContentId = specification.publishedContentId;

    if (publishedContentId != null && publishedContentId.isNotEmpty) {
      final lesson = await lessonRepository.getPublishedLessonById(
        publishedContentId,
        languageCode,
      );

      if (lesson != null) {
        return _LessonDetailState.ready(lesson);
      }
    }

    return _requestMissingLessonContent(specification, languageCode);
  }

  Future<_LessonDetailState> _requestMissingLessonContent(
    LessonSpecification specification,
    String languageCode,
  ) async {
    final generationRepository = ContentGenerationRepositoryScope.of(context);
    final lessonRepository = LessonRepositoryScope.of(context);
    final result = await generationRepository.requestLessonContent(
      schoolId: specification.schoolId,
      courseOfferingId: specification.courseOfferingId,
      courseId: specification.courseId,
      lessonSpecificationId: specification.id,
      languageCode: languageCode,
    );

    final readyResult = result.isPending && result.requestId != null
        ? await _pollGenerationStatus(result, specification.schoolId)
        : result;

    if (!readyResult.isReady || readyResult.publishedContentId == null) {
      return _LessonDetailState.failed(readyResult.message);
    }

    final lesson = await lessonRepository.getPublishedLessonById(
      readyResult.publishedContentId!,
      languageCode,
    );

    if (lesson == null) {
      return _LessonDetailState.failed(readyResult.message);
    }

    return _LessonDetailState.ready(lesson);
  }

  Future<ContentGenerationResult> _pollGenerationStatus(
    ContentGenerationResult initialResult,
    String schoolId,
  ) async {
    final requestId = initialResult.requestId;

    if (requestId == null) {
      return initialResult;
    }

    final generationRepository = ContentGenerationRepositoryScope.of(context);

    for (var attempt = 0; attempt < 3; attempt += 1) {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final result = await generationRepository.getContentGenerationStatus(
        schoolId: schoolId,
        requestId: requestId,
      );

      if (!result.isPending) {
        return result;
      }
    }

    return initialResult;
  }

  void _retry() {
    setState(() {
      _lessonFuture = _resolveLesson();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final course = CourseRepositoryScope.of(
      context,
    ).getCourseById(widget.courseId, languageCode);
    return FutureBuilder<_LessonDetailState>(
      future: _lessonFuture,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state?.lesson != null) {
          return _LessonDetailContent(
            courseId: widget.courseId,
            lesson: state!.lesson!,
            courseTitle: course.title,
          );
        }

        if (state?.isFailed ?? false) {
          return _LessonDetailStatusScaffold(
            courseId: widget.courseId,
            courseTitle: course.title,
            title: context.l10n.lessonContentUnavailableTitle,
            message: state?.message ?? context.l10n.lessonContentUnavailable,
            actionLabel: context.l10n.retryLessonContent,
            onAction: _retry,
          );
        }

        return _LessonDetailStatusScaffold(
          courseId: widget.courseId,
          courseTitle: course.title,
          title: context.l10n.gettingLessonTitle,
          message: context.l10n.gettingLessonMessage,
        );
      },
    );
  }
}

class _LessonDetailContent extends StatelessWidget {
  const _LessonDetailContent({
    required this.courseId,
    required this.lesson,
    required this.courseTitle,
  });

  final String courseId;
  final Lesson lesson;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final steps = [...lesson.steps]..sort((a, b) => a.order.compareTo(b.order));

    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(
          label: courseTitle,
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

class _LessonDetailStatusScaffold extends StatelessWidget {
  const _LessonDetailStatusScaffold({
    required this.courseId,
    required this.courseTitle,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String courseId;
  final String courseTitle;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(
          label: courseTitle,
          onTap: () => context.goNamed(
            RouteNames.lessonList,
            pathParameters: {'courseId': courseId},
          ),
        ),
        AppBreadcrumb(label: title),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToLessons,
        onPressed: () => context.goNamed(
          RouteNames.lessonList,
          pathParameters: {'courseId': courseId},
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actionLabel == null)
                const CircularProgressIndicator()
              else
                Icon(
                  Icons.error_outline,
                  color: context.colorScheme.error,
                  size: 40,
                ),
              const SizedBox(height: 20),
              Text(title, style: context.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonDetailState {
  const _LessonDetailState._({this.lesson, this.message});

  factory _LessonDetailState.ready(Lesson lesson) {
    return _LessonDetailState._(lesson: lesson);
  }

  factory _LessonDetailState.failed(String? message) {
    return _LessonDetailState._(message: message);
  }

  final Lesson? lesson;
  final String? message;

  bool get isFailed => lesson == null;
}
