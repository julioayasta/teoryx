import '../entities/content_generation_result.dart';

abstract class ContentGenerationRepository {
  Future<ContentGenerationResult> requestLessonContent({
    required String schoolId,
    required String courseOfferingId,
    required String courseId,
    required String lessonSpecificationId,
    required String languageCode,
  });

  Future<ContentGenerationResult> getContentGenerationStatus({
    required String schoolId,
    required String requestId,
  });
}
