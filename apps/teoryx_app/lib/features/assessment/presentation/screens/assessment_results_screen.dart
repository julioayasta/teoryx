import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/data/repositories/mock_course_repository.dart';
import '../../../../features/progress/data/repositories/mock_progress_repository.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_assessment_repository.dart';
import '../../domain/entities/assessment_answer.dart';
import '../../domain/entities/assessment_question_type.dart';
import '../../../progress/domain/entities/student_progress.dart';

class AssessmentResultsScreen extends StatelessWidget {
  const AssessmentResultsScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  static const _assessmentRepository = MockAssessmentRepository();
  static const _courseRepository = MockCourseRepository();
  static const _progressRepository = MockProgressRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final course = _courseRepository.getCourseById(courseId, languageCode);
    final assessment = _assessmentRepository.getAssessmentForLesson(
      lessonId,
      languageCode,
    );
    final result = _assessmentRepository.gradeAttempt(
      assessment: assessment,
      attempt: _assessmentRepository.createAttempt(
        assessment: assessment,
        studentId: 'student-001',
        answers: const [
          AssessmentAnswer(
            questionId: 'q1',
            questionType: AssessmentQuestionType.multipleChoice,
            gradingStatus: AssessmentGradingStatus.notGraded,
            answerValue: '1/4',
          ),
          AssessmentAnswer(
            questionId: 'q2',
            questionType: AssessmentQuestionType.trueFalse,
            gradingStatus: AssessmentGradingStatus.notGraded,
            answerValue: 'true',
          ),
          AssessmentAnswer(
            questionId: 'q3',
            questionType: AssessmentQuestionType.multipleChoice,
            gradingStatus: AssessmentGradingStatus.notGraded,
            answerValue: '8/3',
          ),
          AssessmentAnswer(
            questionId: 'q4',
            questionType: AssessmentQuestionType.writtenResponse,
            gradingStatus: AssessmentGradingStatus.notGraded,
            textResponse: 'The denominator names all equal parts.',
          ),
          AssessmentAnswer(
            questionId: 'q5',
            questionType: AssessmentQuestionType.documentUpload,
            gradingStatus: AssessmentGradingStatus.notGraded,
            documentAttached: true,
            documentName: 'fraction-work.pdf',
          ),
        ],
      ),
    );
    _progressRepository.markAssessmentCompleted(
      autoGradedScorePercentage: result.autoGradedScorePercentage,
      pendingReviewCount: result.pendingReviewCount,
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
            pathParameters: {'courseId': courseId},
          ),
        ),
        AppBreadcrumb(label: context.l10n.resultsTitle),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToAssessment,
        onPressed: () => context.goNamed(
          RouteNames.assessment,
          pathParameters: {'courseId': courseId, 'lessonId': lessonId},
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
          Text(
            context.l10n.resultsTitle,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _ResultTile(
            label: context.l10n.autoGradedScore,
            value: '${result.autoGradedScorePercentage}%',
          ),
          _ResultTile(
            label: context.l10n.finalScore,
            value: result.finalScorePercentage == null
                ? context.l10n.pendingReview
                : '${result.finalScorePercentage}%',
          ),
          _ResultTile(
            label: context.l10n.correctAnswers,
            value: '${result.correctCount}',
          ),
          _ResultTile(
            label: context.l10n.incorrectAnswers,
            value: '${result.incorrectCount}',
          ),
          _ResultTile(
            label: context.l10n.pendingReviewItems,
            value: '${result.pendingReviewCount}',
          ),
          _ResultTile(
            label: context.l10n.masteryLevelLabel,
            value: _masteryLabel(context, result.masteryLevel),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.goNamed(RouteNames.studentDashboard),
            icon: const Icon(Icons.dashboard_outlined),
            label: Text(context.l10n.returnToDashboard),
          ),
        ],
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

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: context.textTheme.titleMedium),
      ),
    );
  }
}
