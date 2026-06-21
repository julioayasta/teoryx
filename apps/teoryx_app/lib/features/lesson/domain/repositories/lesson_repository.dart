import '../entities/lesson.dart';

abstract class LessonRepository {
  List<Lesson> getAvailableLessons([String languageCode = 'en']);

  List<Lesson> getLessonsForCourse(String courseId, String languageCode);

  Lesson getLessonById(String lessonId, String languageCode);

  Future<Lesson?> getPublishedLessonById(String lessonId, String languageCode);
}
