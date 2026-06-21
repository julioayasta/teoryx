import '../entities/lesson_specification.dart';

abstract class LessonSpecificationRepository {
  Future<List<LessonSpecification>> getLessonSpecificationsForCourse(
    String courseId,
    String languageCode,
  );

  Future<LessonSpecification?> getLessonSpecificationById(
    String lessonSpecificationId,
    String languageCode,
  );
}
