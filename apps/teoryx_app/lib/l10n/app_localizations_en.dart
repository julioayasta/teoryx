// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TeoryX';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageSpanish => 'ES';

  @override
  String get foundationReadyTitle => 'Foundation ready';

  @override
  String get foundationReadyMessage =>
      'The application architecture is prepared for K-12 curriculum-based learning.';

  @override
  String get welcomeTitle => 'Welcome to TeoryX';

  @override
  String get welcomeMessage =>
      'Start a curriculum-based learning session with local prototype data.';

  @override
  String get mockLoginTitle => 'Choose a mock role';

  @override
  String get mockLoginMessage =>
      'Use prototype access to review the student learning experience.';

  @override
  String get roleSelectionMessage =>
      'Choose a role to preview the prototype. Real authentication will come later.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get continueAsStudent => 'Continue as Student';

  @override
  String get continueAsParent => 'Continue as Parent';

  @override
  String get continueAsSchoolAdmin => 'Continue as School Admin';

  @override
  String get dashboardTitle => 'Student Dashboard';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get studentMetadataPlaceholder =>
      'Student details will appear here in a future sprint.';

  @override
  String studentGreeting(Object firstName) {
    return 'Hello, $firstName';
  }

  @override
  String get availableLessonsTitle => 'Available lessons';

  @override
  String get viewAllLessons => 'View all lessons';

  @override
  String get readyToLearnTitle => 'Ready to learn?';

  @override
  String get continueLearningTitle => 'Continue learning';

  @override
  String get continueStudyingTitle => 'Continue Studying';

  @override
  String get continueLearningAction => 'Continue';

  @override
  String get continueAssessmentAction => 'Continue Assessment';

  @override
  String get continueWithNextLessonAction => 'Continue with Next Lesson';

  @override
  String get noStartedCourses => 'No started courses yet.';

  @override
  String get startedCourseLabel => 'Started course';

  @override
  String get currentLessonLabel => 'Current Lesson:';

  @override
  String get continueLessonLabel => 'Continue:';

  @override
  String get continueAssessmentLabel => 'Continue Assessment:';

  @override
  String get recommendedNextLabel => 'Recommended next:';

  @override
  String get previousLessonLabel => 'Previous lesson:';

  @override
  String previousLessonCompleted(Object lessonTitle) {
    return '$lessonTitle completed';
  }

  @override
  String get currentLessonComparingFractions => 'Comparing Fractions';

  @override
  String get progressLabel => 'Progress:';

  @override
  String get lessonProgressTwoOfEight => 'Lesson 2 of 8';

  @override
  String get studentMetricsTitle => 'Student metrics';

  @override
  String get weeklyGoalMetric => 'Weekly Goal';

  @override
  String get learningStreakMetric => 'Learning Streak';

  @override
  String get masteryScoreMetric => 'Mastery Score';

  @override
  String get lessonsCompletedMetric => 'Lessons Completed';

  @override
  String get courseCatalogTitle => 'Course catalog';

  @override
  String get chooseCourseFromDashboard =>
      'Choose a course first, then pick the lesson you want to study.';

  @override
  String get chooseCourse => 'Choose course';

  @override
  String get chooseNewCourse => 'Choose New Course';

  @override
  String get newCourseFromCatalog => 'New Course from Catalog';

  @override
  String get gradeSelectionTitle => 'Choose Grade';

  @override
  String get chooseGradePrompt => 'Select your grade level.';

  @override
  String get courseSelectionTitle => 'Choose Course';

  @override
  String get chooseCoursePrompt =>
      'Select the subject you want to work on today.';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get backToGrades => 'Back to Grades';

  @override
  String get backToCourses => 'Back to Courses';

  @override
  String get backToLessons => 'Back to Lessons';

  @override
  String get noCoursesForGrade =>
      'Courses for this grade are not available in the prototype yet.';

  @override
  String get noLessonsForCourse =>
      'Lessons for this course are not available in the prototype yet.';

  @override
  String get lessonListTitle => 'Lessons';

  @override
  String get standardLabel => 'Standard:';

  @override
  String get bigIdeaLabel => 'Big Idea';

  @override
  String get essentialQuestionLabel => 'Essential Question';

  @override
  String get learningObjectiveLabel => 'Learning Objective';

  @override
  String get lessonContentLabel => 'Lesson Content';

  @override
  String get guidedPracticeLabel => 'Guided Practice';

  @override
  String get independentPracticeLabel => 'Independent Practice';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get askTutor => 'Ask Tutor';

  @override
  String get tutorChatTitle => 'Tutor Chat';

  @override
  String get closeTutorChat => 'Close tutor chat';

  @override
  String get mockTutorInputHint => 'Mock tutor input disabled';

  @override
  String get guidedLessonTitle => 'Guided Lesson';

  @override
  String get guidedLessonIntro =>
      'Let\'s catch you up step by step. Read the story, pause at the questions, and use the tutor whenever you want help without leaving the lesson.';

  @override
  String get learningDetailsTitle => 'Learning details';

  @override
  String get lessonStepTypeStory => 'Story';

  @override
  String get lessonStepTypeImagePlaceholder => 'Image Placeholder';

  @override
  String get lessonStepTypeExplanation => 'Explanation';

  @override
  String get lessonStepTypeQuestion => 'Question';

  @override
  String get lessonStepTypePractice => 'Practice';

  @override
  String get lessonStepTypeSummary => 'Summary';

  @override
  String get lessonStepPromptLabel => 'Prompt';

  @override
  String get lessonStepExpectedAnswerLabel => 'Expected Answer';

  @override
  String get startAssessment => 'Start Assessment';

  @override
  String get assessmentTitle => 'Assessment';

  @override
  String get assessmentIntro =>
      'Answer each question. Multiple choice and true/false are auto-graded; written work and document work may need review.';

  @override
  String get submitAssessment => 'Submit Assessment';

  @override
  String get writtenResponseHint => 'Write your explanation here.';

  @override
  String get uploadComingSoon => 'Upload feature coming soon';

  @override
  String get mockDocumentAttached => 'Mock document attached';

  @override
  String get markDocumentAttached => 'Mark document attached';

  @override
  String get resultsTitle => 'Results';

  @override
  String get backToLesson => 'Back to Lesson';

  @override
  String get backToAssessment => 'Back to Assessment';

  @override
  String get autoGradedScore => 'Auto-graded score';

  @override
  String get finalScore => 'Final score';

  @override
  String get pendingReview => 'Pending review';

  @override
  String get correctAnswers => 'Correct answers';

  @override
  String get incorrectAnswers => 'Incorrect answers';

  @override
  String get pendingReviewItems => 'Pending review items';

  @override
  String get masteryLevelLabel => 'Mastery level';

  @override
  String get returnToDashboard => 'Return to Dashboard';

  @override
  String get masteryNotStarted => 'Not started';

  @override
  String get masteryInProgress => 'In progress';

  @override
  String get masteryDeveloping => 'Developing';

  @override
  String get masteryProficient => 'Proficient';

  @override
  String get masteryMastered => 'Mastered';

  @override
  String get lastAssessmentScoreLabel => 'Last Assessment Score:';

  @override
  String autoGradedScoreValue(int score) {
    return '$score% auto-graded';
  }

  @override
  String get masteryStateLabel => 'Mastery:';

  @override
  String get pendingReviewNotice => 'Pending review:';

  @override
  String pendingReviewCountValue(int count) {
    return '$count items';
  }
}
