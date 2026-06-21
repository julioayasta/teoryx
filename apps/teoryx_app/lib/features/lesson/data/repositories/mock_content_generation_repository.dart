import '../../domain/entities/content_generation_result.dart';
import '../../domain/repositories/content_generation_repository.dart';

class MockContentGenerationRepository implements ContentGenerationRepository {
  const MockContentGenerationRepository();

  @override
  Future<ContentGenerationResult> getContentGenerationStatus({
    required String schoolId,
    required String requestId,
  }) async {
    return const ContentGenerationResult(
      status: ContentGenerationStatus.failed,
      message: 'Content generation is unavailable in mock mode.',
    );
  }

  @override
  Future<ContentGenerationResult> requestLessonContent({
    required String schoolId,
    required String courseOfferingId,
    required String courseId,
    required String lessonSpecificationId,
    required String languageCode,
  }) async {
    return const ContentGenerationResult(
      status: ContentGenerationStatus.failed,
      message: 'Content generation is unavailable in mock mode.',
    );
  }
}
