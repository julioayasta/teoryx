import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/content_generation_result.dart';
import '../../domain/repositories/content_generation_repository.dart';
import 'mock_content_generation_repository.dart';

class FirebaseContentGenerationRepository
    implements ContentGenerationRepository {
  FirebaseContentGenerationRepository({
    FirebaseFunctions? functions,
    ContentGenerationRepository? fallbackRepository,
  }) : _functions = functions,
       _fallbackRepository =
           fallbackRepository ?? const MockContentGenerationRepository();

  final FirebaseFunctions? _functions;
  final ContentGenerationRepository _fallbackRepository;

  @override
  Future<ContentGenerationResult> requestLessonContent({
    required String schoolId,
    required String courseOfferingId,
    required String courseId,
    required String lessonSpecificationId,
    required String languageCode,
  }) async {
    try {
      final callable = (_functions ?? FirebaseFunctions.instance).httpsCallable(
        'requestLessonContent',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'courseOfferingId': courseOfferingId,
        'courseId': courseId,
        'lessonSpecificationId': lessonSpecificationId,
        'language': languageCode,
      });

      return _resultFromMap(result.data);
    } on Object {
      return _fallbackRepository.requestLessonContent(
        schoolId: schoolId,
        courseOfferingId: courseOfferingId,
        courseId: courseId,
        lessonSpecificationId: lessonSpecificationId,
        languageCode: languageCode,
      );
    }
  }

  @override
  Future<ContentGenerationResult> getContentGenerationStatus({
    required String schoolId,
    required String requestId,
  }) async {
    try {
      final callable = (_functions ?? FirebaseFunctions.instance).httpsCallable(
        'getContentGenerationStatus',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'requestId': requestId,
      });

      return _resultFromMap(result.data);
    } on Object {
      return _fallbackRepository.getContentGenerationStatus(
        schoolId: schoolId,
        requestId: requestId,
      );
    }
  }

  ContentGenerationResult _resultFromMap(Map<String, dynamic> data) {
    return ContentGenerationResult(
      status: _statusFromString(data['status'] as String?),
      requestId: data['requestId'] as String?,
      publishedContentId: data['publishedContentId'] as String?,
      message: data['message'] as String?,
    );
  }

  ContentGenerationStatus _statusFromString(String? value) {
    return switch (value) {
      'ready' => ContentGenerationStatus.ready,
      'failed' => ContentGenerationStatus.failed,
      _ => ContentGenerationStatus.pending,
    };
  }
}
