import '../../domain/entities/lesson_specification.dart';
import '../../domain/repositories/lesson_specification_repository.dart';

class MockLessonSpecificationRepository
    implements LessonSpecificationRepository {
  const MockLessonSpecificationRepository();

  @override
  Future<LessonSpecification?> getLessonSpecificationById(
    String lessonSpecificationId,
    String languageCode,
  ) async {
    return null;
  }

  @override
  Future<List<LessonSpecification>> getLessonSpecificationsForCourse(
    String courseId,
    String languageCode,
  ) async {
    return const [];
  }
}
