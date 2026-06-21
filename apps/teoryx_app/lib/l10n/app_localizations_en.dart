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
  String get continueAsStudent => 'Continue as Student';

  @override
  String get dashboardTitle => 'Student Dashboard';

  @override
  String studentGreeting(Object firstName) {
    return 'Hello, $firstName';
  }

  @override
  String get availableLessonsTitle => 'Available lessons';

  @override
  String get viewAllLessons => 'View all lessons';

  @override
  String get lessonListTitle => 'Lessons';

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
  String get mockTutorInputHint => 'Mock tutor input disabled';
}
