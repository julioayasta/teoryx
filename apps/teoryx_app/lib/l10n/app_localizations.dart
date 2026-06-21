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

  /// No description provided for @continueAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Continue as Student'**
  String get continueAsStudent;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Dashboard'**
  String get dashboardTitle;

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

  /// No description provided for @lessonListTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonListTitle;

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
