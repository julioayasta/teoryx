import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TeoryX'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'ES'**
  String get languageSpanish;

  /// No description provided for @foundationReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation ready'**
  String get foundationReadyTitle;

  /// No description provided for @foundationReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'The application architecture is prepared for K-12 curriculum-based learning.'**
  String get foundationReadyMessage;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TeoryX'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a curriculum-based learning session with local prototype data.'**
  String get welcomeMessage;

  /// No description provided for @mockLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a mock role'**
  String get mockLoginTitle;

  /// No description provided for @mockLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Use prototype access to review the student learning experience.'**
  String get mockLoginMessage;

  /// No description provided for @roleSelectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a role to preview the prototype. Real authentication will come later.'**
  String get roleSelectionMessage;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Continue as Student'**
  String get continueAsStudent;

  /// No description provided for @continueAsParent.
  ///
  /// In en, this message translates to:
  /// **'Continue as Parent'**
  String get continueAsParent;

  /// No description provided for @continueAsSchoolAdmin.
  ///
  /// In en, this message translates to:
  /// **'Continue as School Admin'**
  String get continueAsSchoolAdmin;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Dashboard'**
  String get dashboardTitle;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @studentMetadataPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Student details will appear here in a future sprint.'**
  String get studentMetadataPlaceholder;

  /// No description provided for @studentGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {firstName}'**
  String studentGreeting(Object firstName);

  /// No description provided for @availableLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available lessons'**
  String get availableLessonsTitle;

  /// No description provided for @viewAllLessons.
  ///
  /// In en, this message translates to:
  /// **'View all lessons'**
  String get viewAllLessons;

  /// No description provided for @readyToLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn?'**
  String get readyToLearnTitle;

  /// No description provided for @continueLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearningTitle;

  /// No description provided for @continueStudyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Studying'**
  String get continueStudyingTitle;

  /// No description provided for @continueLearningAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLearningAction;

  /// No description provided for @noStartedCourses.
  ///
  /// In en, this message translates to:
  /// **'No started courses yet.'**
  String get noStartedCourses;

  /// No description provided for @startedCourseLabel.
  ///
  /// In en, this message translates to:
  /// **'Started course'**
  String get startedCourseLabel;

  /// No description provided for @currentLessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Lesson:'**
  String get currentLessonLabel;

  /// No description provided for @currentLessonComparingFractions.
  ///
  /// In en, this message translates to:
  /// **'Comparing Fractions'**
  String get currentLessonComparingFractions;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress:'**
  String get progressLabel;

  /// No description provided for @lessonProgressTwoOfEight.
  ///
  /// In en, this message translates to:
  /// **'Lesson 2 of 8'**
  String get lessonProgressTwoOfEight;

  /// No description provided for @studentMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student metrics'**
  String get studentMetricsTitle;

  /// No description provided for @weeklyGoalMetric.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoalMetric;

  /// No description provided for @learningStreakMetric.
  ///
  /// In en, this message translates to:
  /// **'Learning Streak'**
  String get learningStreakMetric;

  /// No description provided for @masteryScoreMetric.
  ///
  /// In en, this message translates to:
  /// **'Mastery Score'**
  String get masteryScoreMetric;

  /// No description provided for @lessonsCompletedMetric.
  ///
  /// In en, this message translates to:
  /// **'Lessons Completed'**
  String get lessonsCompletedMetric;

  /// No description provided for @courseCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Course catalog'**
  String get courseCatalogTitle;

  /// No description provided for @chooseCourseFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Choose a course first, then pick the lesson you want to study.'**
  String get chooseCourseFromDashboard;

  /// No description provided for @chooseCourse.
  ///
  /// In en, this message translates to:
  /// **'Choose course'**
  String get chooseCourse;

  /// No description provided for @chooseNewCourse.
  ///
  /// In en, this message translates to:
  /// **'Choose New Course'**
  String get chooseNewCourse;

  /// No description provided for @newCourseFromCatalog.
  ///
  /// In en, this message translates to:
  /// **'New Course from Catalog'**
  String get newCourseFromCatalog;

  /// No description provided for @gradeSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Grade'**
  String get gradeSelectionTitle;

  /// No description provided for @chooseGradePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select your grade level.'**
  String get chooseGradePrompt;

  /// No description provided for @courseSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Course'**
  String get courseSelectionTitle;

  /// No description provided for @chooseCoursePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select the subject you want to work on today.'**
  String get chooseCoursePrompt;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @backToGrades.
  ///
  /// In en, this message translates to:
  /// **'Back to Grades'**
  String get backToGrades;

  /// No description provided for @backToCourses.
  ///
  /// In en, this message translates to:
  /// **'Back to Courses'**
  String get backToCourses;

  /// No description provided for @backToLessons.
  ///
  /// In en, this message translates to:
  /// **'Back to Lessons'**
  String get backToLessons;

  /// No description provided for @noCoursesForGrade.
  ///
  /// In en, this message translates to:
  /// **'Courses for this grade are not available in the prototype yet.'**
  String get noCoursesForGrade;

  /// No description provided for @noLessonsForCourse.
  ///
  /// In en, this message translates to:
  /// **'Lessons for this course are not available in the prototype yet.'**
  String get noLessonsForCourse;

  /// No description provided for @lessonListTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonListTitle;

  /// No description provided for @standardLabel.
  ///
  /// In en, this message translates to:
  /// **'Standard:'**
  String get standardLabel;

  /// No description provided for @bigIdeaLabel.
  ///
  /// In en, this message translates to:
  /// **'Big Idea'**
  String get bigIdeaLabel;

  /// No description provided for @essentialQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Essential Question'**
  String get essentialQuestionLabel;

  /// No description provided for @learningObjectiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning Objective'**
  String get learningObjectiveLabel;

  /// No description provided for @lessonContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson Content'**
  String get lessonContentLabel;

  /// No description provided for @guidedPracticeLabel.
  ///
  /// In en, this message translates to:
  /// **'Guided Practice'**
  String get guidedPracticeLabel;

  /// No description provided for @independentPracticeLabel.
  ///
  /// In en, this message translates to:
  /// **'Independent Practice'**
  String get independentPracticeLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// No description provided for @askTutor.
  ///
  /// In en, this message translates to:
  /// **'Ask Tutor'**
  String get askTutor;

  /// No description provided for @tutorChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutor Chat'**
  String get tutorChatTitle;

  /// No description provided for @closeTutorChat.
  ///
  /// In en, this message translates to:
  /// **'Close tutor chat'**
  String get closeTutorChat;

  /// No description provided for @mockTutorInputHint.
  ///
  /// In en, this message translates to:
  /// **'Mock tutor input disabled'**
  String get mockTutorInputHint;

  /// No description provided for @guidedLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided Lesson'**
  String get guidedLessonTitle;

  /// No description provided for @guidedLessonIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s catch you up step by step. Read the story, pause at the questions, and use the tutor whenever you want help without leaving the lesson.'**
  String get guidedLessonIntro;

  /// No description provided for @learningDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning details'**
  String get learningDetailsTitle;

  /// No description provided for @lessonStepTypeStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get lessonStepTypeStory;

  /// No description provided for @lessonStepTypeImagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Image Placeholder'**
  String get lessonStepTypeImagePlaceholder;

  /// No description provided for @lessonStepTypeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get lessonStepTypeExplanation;

  /// No description provided for @lessonStepTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get lessonStepTypeQuestion;

  /// No description provided for @lessonStepTypePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get lessonStepTypePractice;

  /// No description provided for @lessonStepTypeSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get lessonStepTypeSummary;

  /// No description provided for @lessonStepPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get lessonStepPromptLabel;

  /// No description provided for @lessonStepExpectedAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected Answer'**
  String get lessonStepExpectedAnswerLabel;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start Assessment'**
  String get startAssessment;

  /// No description provided for @assessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessmentTitle;

  /// No description provided for @assessmentIntro.
  ///
  /// In en, this message translates to:
  /// **'Answer each question. Multiple choice and true/false are auto-graded; written work and document work may need review.'**
  String get assessmentIntro;

  /// No description provided for @submitAssessment.
  ///
  /// In en, this message translates to:
  /// **'Submit Assessment'**
  String get submitAssessment;

  /// No description provided for @writtenResponseHint.
  ///
  /// In en, this message translates to:
  /// **'Write your explanation here.'**
  String get writtenResponseHint;

  /// No description provided for @uploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Upload feature coming soon'**
  String get uploadComingSoon;

  /// No description provided for @mockDocumentAttached.
  ///
  /// In en, this message translates to:
  /// **'Mock document attached'**
  String get mockDocumentAttached;

  /// No description provided for @markDocumentAttached.
  ///
  /// In en, this message translates to:
  /// **'Mark document attached'**
  String get markDocumentAttached;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @backToLesson.
  ///
  /// In en, this message translates to:
  /// **'Back to Lesson'**
  String get backToLesson;

  /// No description provided for @backToAssessment.
  ///
  /// In en, this message translates to:
  /// **'Back to Assessment'**
  String get backToAssessment;

  /// No description provided for @autoGradedScore.
  ///
  /// In en, this message translates to:
  /// **'Auto-graded score'**
  String get autoGradedScore;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final score'**
  String get finalScore;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get pendingReview;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswers;

  /// No description provided for @incorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answers'**
  String get incorrectAnswers;

  /// No description provided for @pendingReviewItems.
  ///
  /// In en, this message translates to:
  /// **'Pending review items'**
  String get pendingReviewItems;

  /// No description provided for @masteryLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastery level'**
  String get masteryLevelLabel;

  /// No description provided for @returnToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to Dashboard'**
  String get returnToDashboard;

  /// No description provided for @masteryNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get masteryNotStarted;

  /// No description provided for @masteryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get masteryInProgress;

  /// No description provided for @masteryDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Developing'**
  String get masteryDeveloping;

  /// No description provided for @masteryProficient.
  ///
  /// In en, this message translates to:
  /// **'Proficient'**
  String get masteryProficient;

  /// No description provided for @masteryMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get masteryMastered;

  /// No description provided for @lastAssessmentScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Assessment Score:'**
  String get lastAssessmentScoreLabel;

  /// No description provided for @masteryStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastery:'**
  String get masteryStateLabel;

  /// No description provided for @pendingReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Review:'**
  String get pendingReviewNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
