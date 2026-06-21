import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/data/repositories/mock_course_repository.dart';
import '../../../../features/progress/data/repositories/mock_progress_repository.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_assessment_repository.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/assessment_answer.dart';
import '../../domain/entities/assessment_question.dart';
import '../../domain/entities/assessment_question_type.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  static const _assessmentRepository = MockAssessmentRepository();
  static const _courseRepository = MockCourseRepository();
  static const _progressRepository = MockProgressRepository();

  final _selectedValues = <String, String>{};
  final _writtenResponses = <String, String>{};
  final _documentAttached = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _progressRepository.markAssessmentStarted();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final assessment = _assessmentRepository.getAssessmentForLesson(
      widget.lessonId,
      languageCode,
    );
    final course = _courseRepository.getCourseById(
      widget.courseId,
      languageCode,
    );

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
            pathParameters: {'courseId': widget.courseId},
          ),
        ),
        AppBreadcrumb(label: context.l10n.assessmentTitle),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToLesson,
        onPressed: () => context.goNamed(
          RouteNames.lessonDetail,
          pathParameters: {
            'courseId': widget.courseId,
            'lessonId': widget.lessonId,
          },
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(assessment.title, style: context.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.assessmentIntro,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          for (final question in assessment.questions)
            _QuestionCard(
              question: question,
              selectedValue: _selectedValues[question.id],
              writtenResponse: _writtenResponses[question.id] ?? '',
              documentAttached: _documentAttached[question.id] ?? false,
              onSelected: (value) {
                setState(() => _selectedValues[question.id] = value);
              },
              onWrittenChanged: (value) {
                _writtenResponses[question.id] = value;
              },
              onDocumentToggle: () {
                setState(() {
                  _documentAttached[question.id] =
                      !(_documentAttached[question.id] ?? false);
                });
              },
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _submit(assessment),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(context.l10n.submitAssessment),
          ),
        ],
      ),
    );
  }

  void _submit(Assessment assessment) {
    final answers = assessment.questions.map((question) {
      final selectedValue = _selectedValues[question.id];
      final selectedOption = question.answerOptions
          .where((option) => option.value == selectedValue)
          .firstOrNull;

      return AssessmentAnswer(
        questionId: question.id,
        questionType: question.type,
        gradingStatus: AssessmentGradingStatus.notGraded,
        selectedOptionId: selectedOption?.id,
        answerValue: selectedValue,
        textResponse: _writtenResponses[question.id],
        documentAttached: _documentAttached[question.id] ?? false,
        documentName: (_documentAttached[question.id] ?? false)
            ? 'fraction-work.pdf'
            : null,
      );
    }).toList();

    final attempt = _assessmentRepository.createAttempt(
      assessment: assessment,
      studentId: 'student-001',
      answers: answers,
    );
    final result = _assessmentRepository.gradeAttempt(
      assessment: assessment,
      attempt: attempt,
    );
    _progressRepository.markAssessmentCompleted(
      autoGradedScorePercentage: result.autoGradedScorePercentage,
      pendingReviewCount: result.pendingReviewCount,
    );

    context.goNamed(
      RouteNames.assessmentResults,
      pathParameters: {
        'courseId': widget.courseId,
        'lessonId': widget.lessonId,
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedValue,
    required this.writtenResponse,
    required this.documentAttached,
    required this.onSelected,
    required this.onWrittenChanged,
    required this.onDocumentToggle,
  });

  final AssessmentQuestion question;
  final String? selectedValue;
  final String writtenResponse;
  final bool documentAttached;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onWrittenChanged;
  final VoidCallback onDocumentToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question.order}. ${question.prompt}',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            switch (question.type) {
              AssessmentQuestionType.multipleChoice ||
              AssessmentQuestionType.trueFalse => Column(
                children: [
                  RadioGroup<String>(
                    groupValue: selectedValue,
                    onChanged: (value) {
                      if (value != null) {
                        onSelected(value);
                      }
                    },
                    child: Column(
                      children: [
                        for (final option in question.answerOptions)
                          RadioListTile<String>(
                            value: option.value,
                            title: Text(option.label),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              AssessmentQuestionType.writtenResponse => TextField(
                minLines: 4,
                maxLines: 6,
                onChanged: onWrittenChanged,
                decoration: InputDecoration(
                  hintText: context.l10n.writtenResponseHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              AssessmentQuestionType.documentUpload =>
                _DocumentUploadPlaceholder(
                  documentAttached: documentAttached,
                  onDocumentToggle: onDocumentToggle,
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _DocumentUploadPlaceholder extends StatelessWidget {
  const _DocumentUploadPlaceholder({
    required this.documentAttached,
    required this.onDocumentToggle,
  });

  final bool documentAttached;
  final VoidCallback onDocumentToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(context.l10n.uploadComingSoon)),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onDocumentToggle,
              icon: Icon(
                documentAttached
                    ? Icons.check_circle_outline
                    : Icons.attach_file_outlined,
              ),
              label: Text(
                documentAttached
                    ? context.l10n.mockDocumentAttached
                    : context.l10n.markDocumentAttached,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
