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
  String get languageEnglish => 'EN';

  @override
  String get languageSpanish => 'ES';

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
  String get mockLoginTitle => 'Elige un rol mock';

  @override
  String get mockLoginMessage =>
      'Usa acceso de prototipo para revisar la experiencia de aprendizaje del estudiante.';

  @override
  String get roleSelectionMessage =>
      'Elige un rol para revisar el prototipo. La autenticacion real vendra despues.';

  @override
  String get emailLabel => 'Correo';

  @override
  String get passwordLabel => 'Contrasena';

  @override
  String get signIn => 'Iniciar sesion';

  @override
  String get continueAsStudent => 'Continuar como estudiante';

  @override
  String get continueAsParent => 'Continuar como padre';

  @override
  String get continueAsSchoolAdmin => 'Continuar como administrador escolar';

  @override
  String get dashboardTitle => 'Panel del estudiante';

  @override
  String get backToLogin => 'Volver al login';

  @override
  String get studentMetadataPlaceholder =>
      'Los detalles del estudiante apareceran aqui en un sprint futuro.';

  @override
  String studentGreeting(Object firstName) {
    return 'Hola, $firstName';
  }

  @override
  String get availableLessonsTitle => 'Lecciones disponibles';

  @override
  String get viewAllLessons => 'Ver todas las lecciones';

  @override
  String get readyToLearnTitle => 'Listo para aprender?';

  @override
  String get continueLearningTitle => 'Continuar aprendiendo';

  @override
  String get continueStudyingTitle => 'Continuar estudiando';

  @override
  String get continueLearningAction => 'Continuar';

  @override
  String get noStartedCourses => 'Aun no hay cursos iniciados.';

  @override
  String get startedCourseLabel => 'Curso iniciado';

  @override
  String get currentLessonLabel => 'Leccion actual:';

  @override
  String get currentLessonComparingFractions => 'Comparar fracciones';

  @override
  String get progressLabel => 'Progreso:';

  @override
  String get lessonProgressTwoOfEight => 'Leccion 2 de 8';

  @override
  String get studentMetricsTitle => 'Metricas del estudiante';

  @override
  String get weeklyGoalMetric => 'Meta semanal';

  @override
  String get learningStreakMetric => 'Racha de aprendizaje';

  @override
  String get masteryScoreMetric => 'Nivel de dominio';

  @override
  String get lessonsCompletedMetric => 'Lecciones completadas';

  @override
  String get courseCatalogTitle => 'Catalogo de cursos';

  @override
  String get chooseCourseFromDashboard =>
      'Elige primero un curso y luego selecciona la leccion que quieres estudiar.';

  @override
  String get chooseCourse => 'Elegir curso';

  @override
  String get chooseNewCourse => 'Elegir curso nuevo';

  @override
  String get newCourseFromCatalog => 'Curso nuevo del catalogo';

  @override
  String get gradeSelectionTitle => 'Elegir grado';

  @override
  String get chooseGradePrompt => 'Selecciona tu grado.';

  @override
  String get courseSelectionTitle => 'Elegir curso';

  @override
  String get chooseCoursePrompt =>
      'Selecciona la materia que quieres trabajar hoy.';

  @override
  String get backToDashboard => 'Volver al panel';

  @override
  String get backToGrades => 'Volver a grados';

  @override
  String get backToCourses => 'Volver a cursos';

  @override
  String get backToLessons => 'Volver a lecciones';

  @override
  String get noCoursesForGrade =>
      'Los cursos de este grado aun no estan disponibles en el prototipo.';

  @override
  String get noLessonsForCourse =>
      'Las lecciones de este curso aun no estan disponibles en el prototipo.';

  @override
  String get lessonListTitle => 'Lecciones';

  @override
  String get standardLabel => 'Estandar:';

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
  String get closeTutorChat => 'Cerrar chat con tutor';

  @override
  String get mockTutorInputHint => 'Entrada del tutor mock desactivada';

  @override
  String get guidedLessonTitle => 'Leccion guiada';

  @override
  String get guidedLessonIntro =>
      'Pongamonos al dia paso a paso. Lee la historia, pausa en las preguntas y usa el tutor cuando quieras ayuda sin salir de la leccion.';

  @override
  String get learningDetailsTitle => 'Detalles de aprendizaje';

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

  @override
  String get startAssessment => 'Iniciar evaluacion';

  @override
  String get assessmentTitle => 'Evaluacion';

  @override
  String get assessmentIntro =>
      'Responde cada pregunta. Opcion multiple y verdadero/falso se califican automaticamente; respuestas escritas y documentos pueden requerir revision.';

  @override
  String get submitAssessment => 'Enviar evaluacion';

  @override
  String get writtenResponseHint => 'Escribe tu explicacion aqui.';

  @override
  String get uploadComingSoon =>
      'La carga de archivos estara disponible pronto';

  @override
  String get mockDocumentAttached => 'Documento mock adjuntado';

  @override
  String get markDocumentAttached => 'Marcar documento adjunto';

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get backToLesson => 'Volver a la leccion';

  @override
  String get backToAssessment => 'Volver a la evaluacion';

  @override
  String get autoGradedScore => 'Puntaje autocalificado';

  @override
  String get finalScore => 'Puntaje final';

  @override
  String get pendingReview => 'Revision pendiente';

  @override
  String get correctAnswers => 'Respuestas correctas';

  @override
  String get incorrectAnswers => 'Respuestas incorrectas';

  @override
  String get pendingReviewItems => 'Elementos pendientes de revision';

  @override
  String get masteryLevelLabel => 'Nivel de dominio';

  @override
  String get returnToDashboard => 'Volver al panel';

  @override
  String get masteryNotStarted => 'No iniciado';

  @override
  String get masteryInProgress => 'En progreso';

  @override
  String get masteryDeveloping => 'En desarrollo';

  @override
  String get masteryProficient => 'Competente';

  @override
  String get masteryMastered => 'Dominado';

  @override
  String get lastAssessmentScoreLabel => 'Ultimo puntaje:';

  @override
  String get masteryStateLabel => 'Dominio:';

  @override
  String get pendingReviewNotice => 'Revision:';
}
