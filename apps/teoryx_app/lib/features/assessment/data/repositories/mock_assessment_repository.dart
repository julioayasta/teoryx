import '../../domain/entities/answer_option.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/assessment_answer.dart';
import '../../domain/entities/assessment_attempt.dart';
import '../../domain/entities/assessment_question.dart';
import '../../domain/entities/assessment_question_type.dart';
import '../../domain/entities/assessment_result.dart';
import '../../../progress/domain/entities/student_progress.dart';

class MockAssessmentRepository {
  const MockAssessmentRepository();

  Assessment getAssessmentForLesson(String lessonId, String languageCode) {
    final isSpanish = languageCode == 'es';
    final assessmentId = 'assessment-$lessonId';

    return Assessment(
      id: assessmentId,
      lessonId: lessonId,
      title: isSpanish ? 'Evaluacion de fracciones' : 'Fractions Checkpoint',
      passingScore: 70,
      questions: [
        AssessmentQuestion(
          id: 'q1',
          assessmentId: assessmentId,
          order: 1,
          type: AssessmentQuestionType.multipleChoice,
          prompt: isSpanish
              ? 'Sofia recibe 1 de 4 porciones iguales de pizza. Que fraccion representa su parte?'
              : 'Sofia receives 1 of 4 equal pizza slices. Which fraction represents her share?',
          points: 1,
          correctAnswerValue: '1/4',
          answerOptions: const [
            AnswerOption(id: 'q1-a', label: '1/2', value: '1/2'),
            AnswerOption(id: 'q1-b', label: '1/4', value: '1/4'),
            AnswerOption(id: 'q1-c', label: '4/1', value: '4/1'),
          ],
        ),
        AssessmentQuestion(
          id: 'q2',
          assessmentId: assessmentId,
          order: 2,
          type: AssessmentQuestionType.trueFalse,
          prompt: isSpanish
              ? 'El denominador dice cuantas partes iguales forman el entero.'
              : 'The denominator tells how many equal parts make the whole.',
          points: 1,
          correctAnswerValue: 'true',
          answerOptions: [
            AnswerOption(
              id: 'q2-true',
              label: isSpanish ? 'Verdadero' : 'True',
              value: 'true',
            ),
            AnswerOption(
              id: 'q2-false',
              label: isSpanish ? 'Falso' : 'False',
              value: 'false',
            ),
          ],
        ),
        AssessmentQuestion(
          id: 'q3',
          assessmentId: assessmentId,
          order: 3,
          type: AssessmentQuestionType.multipleChoice,
          prompt: isSpanish
              ? 'Mateo tiene 3 de 8 piezas iguales de pastel. Que fraccion tiene?'
              : 'Mateo has 3 of 8 equal cake pieces. Which fraction does he have?',
          points: 1,
          correctAnswerValue: '3/8',
          answerOptions: const [
            AnswerOption(id: 'q3-a', label: '8/3', value: '8/3'),
            AnswerOption(id: 'q3-b', label: '3/8', value: '3/8'),
            AnswerOption(id: 'q3-c', label: '3/5', value: '3/5'),
          ],
        ),
        AssessmentQuestion(
          id: 'q4',
          assessmentId: assessmentId,
          order: 4,
          type: AssessmentQuestionType.writtenResponse,
          prompt: isSpanish
              ? 'Explica con tus palabras que significan el numerador y el denominador.'
              : 'Explain in your own words what the numerator and denominator mean.',
          points: 1,
        ),
        AssessmentQuestion(
          id: 'q5',
          assessmentId: assessmentId,
          order: 5,
          type: AssessmentQuestionType.documentUpload,
          prompt: isSpanish
              ? 'Adjunta una foto o documento de tu modelo de fraccion dibujado a mano.'
              : 'Attach a photo or document of your handwritten fraction model.',
          points: 1,
        ),
      ],
    );
  }

  AssessmentAttempt createAttempt({
    required Assessment assessment,
    required String studentId,
    required List<AssessmentAnswer> answers,
  }) {
    return AssessmentAttempt(
      id: 'attempt-${assessment.id}',
      assessmentId: assessment.id,
      studentId: studentId,
      lessonId: assessment.lessonId,
      answers: answers,
      submittedAt: DateTime(2026, 6, 21),
    );
  }

  AssessmentResult gradeAttempt({
    required Assessment assessment,
    required AssessmentAttempt attempt,
  }) {
    var autoGradedTotal = 0;
    var autoGradedEarned = 0;
    var correctCount = 0;
    var incorrectCount = 0;
    var pendingReviewCount = 0;

    final gradedAnswers = <AssessmentAnswer>[];

    for (final question in assessment.questions) {
      final answer = attempt.answers.firstWhere(
        (candidate) => candidate.questionId == question.id,
        orElse: () => AssessmentAnswer(
          questionId: question.id,
          questionType: question.type,
          gradingStatus: AssessmentGradingStatus.notGraded,
        ),
      );

      if (question.type == AssessmentQuestionType.multipleChoice ||
          question.type == AssessmentQuestionType.trueFalse) {
        autoGradedTotal += question.points;
        final isCorrect = answer.answerValue == question.correctAnswerValue;
        if (isCorrect) {
          autoGradedEarned += question.points;
          correctCount++;
        } else {
          incorrectCount++;
        }
        gradedAnswers.add(
          AssessmentAnswer(
            questionId: answer.questionId,
            questionType: answer.questionType,
            gradingStatus: AssessmentGradingStatus.autoGraded,
            selectedOptionId: answer.selectedOptionId,
            answerValue: answer.answerValue,
            isCorrect: isCorrect,
            pointsEarned: isCorrect ? question.points : 0,
          ),
        );
      } else {
        pendingReviewCount++;
        gradedAnswers.add(
          AssessmentAnswer(
            questionId: answer.questionId,
            questionType: answer.questionType,
            gradingStatus: AssessmentGradingStatus.pendingReview,
            textResponse: answer.textResponse,
            documentAttached: answer.documentAttached,
            documentName: answer.documentName,
          ),
        );
      }
    }

    final autoScore = autoGradedTotal == 0
        ? 0
        : ((autoGradedEarned / autoGradedTotal) * 100).round();
    final finalScore = pendingReviewCount == 0 ? autoScore : null;

    return AssessmentResult(
      attemptId: attempt.id,
      assessmentId: assessment.id,
      lessonId: assessment.lessonId,
      autoGradedScorePercentage: autoScore,
      finalScorePercentage: finalScore,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      pendingReviewCount: pendingReviewCount,
      masteryLevel: _masteryFor(autoScore, pendingReviewCount),
      answers: gradedAnswers,
    );
  }

  MasteryLevel _masteryFor(int score, int pendingReviewCount) {
    if (pendingReviewCount > 0 && score < 70) {
      return MasteryLevel.developing;
    }
    if (score >= 90) {
      return MasteryLevel.mastered;
    }
    if (score >= 75) {
      return MasteryLevel.proficient;
    }
    if (score >= 50) {
      return MasteryLevel.developing;
    }
    return MasteryLevel.inProgress;
  }
}
