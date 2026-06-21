// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TeoryX';

  @override
  String get foundationReadyTitle => 'Base lista';

  @override
  String get foundationReadyMessage =>
      'La arquitectura de la aplicacion esta preparada para aprendizaje K-12 basado en curriculo.';

  @override
  String get welcomeTitle => 'Bienvenido a TeoryX';

  @override
  String get welcomeMessage =>
      'Inicia una sesion de aprendizaje basada en curriculo con datos locales de prototipo.';

  @override
  String get continueAsStudent => 'Continuar como estudiante';

  @override
  String get dashboardTitle => 'Panel del estudiante';

  @override
  String studentGreeting(Object firstName) {
    return 'Hola, $firstName';
  }

  @override
  String get availableLessonsTitle => 'Lecciones disponibles';

  @override
  String get viewAllLessons => 'Ver todas las lecciones';

  @override
  String get lessonListTitle => 'Lecciones';

  @override
  String get bigIdeaLabel => 'Gran idea';

  @override
  String get essentialQuestionLabel => 'Pregunta esencial';

  @override
  String get learningObjectiveLabel => 'Objetivo de aprendizaje';

  @override
  String get lessonContentLabel => 'Contenido de la leccion';

  @override
  String get guidedPracticeLabel => 'Practica guiada';

  @override
  String get independentPracticeLabel => 'Practica independiente';

  @override
  String get summaryLabel => 'Resumen';

  @override
  String get askTutor => 'Preguntar al tutor';

  @override
  String get tutorChatTitle => 'Chat con tutor';

  @override
  String get mockTutorInputHint => 'Entrada del tutor mock desactivada';

  @override
  String get guidedLessonTitle => 'Leccion guiada';

  @override
  String get lessonStepTypeStory => 'Historia';

  @override
  String get lessonStepTypeImagePlaceholder => 'Marcador de imagen';

  @override
  String get lessonStepTypeExplanation => 'Explicacion';

  @override
  String get lessonStepTypeQuestion => 'Pregunta';

  @override
  String get lessonStepTypePractice => 'Practica';

  @override
  String get lessonStepTypeSummary => 'Resumen';

  @override
  String get lessonStepPromptLabel => 'Consigna';

  @override
  String get lessonStepExpectedAnswerLabel => 'Respuesta esperada';
}
