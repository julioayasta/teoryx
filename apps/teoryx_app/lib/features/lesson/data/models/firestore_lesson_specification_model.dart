import '../../domain/entities/lesson_specification.dart';

class FirestoreLessonSpecificationModel {
  const FirestoreLessonSpecificationModel({
    required this.id,
    required this.lessonId,
    required this.schoolId,
    required this.courseId,
    required this.courseOfferingId,
    required this.title,
    required this.order,
    required this.language,
    required this.generationStatus,
    required this.estimatedDuration,
    required this.difficultyLevel,
    required this.status,
    this.publishedContentId,
  });

  final String id;
  final String lessonId;
  final String schoolId;
  final String courseId;
  final String courseOfferingId;
  final String title;
  final int order;
  final String language;
  final String generationStatus;
  final String estimatedDuration;
  final String difficultyLevel;
  final String status;
  final String? publishedContentId;

  bool get isValid {
    return id.isNotEmpty &&
        lessonId.isNotEmpty &&
        schoolId.isNotEmpty &&
        courseId.isNotEmpty &&
        courseOfferingId.isNotEmpty &&
        title.isNotEmpty &&
        language.isNotEmpty &&
        (status == 'active' || status == 'approved');
  }

  LessonSpecification toEntity() {
    return LessonSpecification(
      id: id,
      lessonId: lessonId,
      schoolId: schoolId,
      courseId: courseId,
      courseOfferingId: courseOfferingId,
      title: title,
      order: order,
      language: language,
      generationStatus: generationStatus,
      estimatedDuration: estimatedDuration,
      difficultyLevel: difficultyLevel,
      publishedContentId: publishedContentId,
    );
  }

  static FirestoreLessonSpecificationModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final courseId = data['courseId'] as String? ?? '';
    final language = data['language'] as String? ?? 'en';

    return FirestoreLessonSpecificationModel(
      id: id,
      lessonId: data['lessonId'] as String? ?? id,
      schoolId: data['schoolId'] as String? ?? '',
      courseId: courseId,
      courseOfferingId:
          data['courseOfferingId'] as String? ??
          'offering-school-demo-$courseId-$language',
      title: data['title'] as String? ?? '',
      order: data['order'] is int ? data['order'] as int : 0,
      language: language,
      generationStatus: data['generationStatus'] as String? ?? 'not_generated',
      estimatedDuration: data['estimatedDuration'] as String? ?? '',
      difficultyLevel: data['difficultyLevel'] as String? ?? '',
      status: data['status'] as String? ?? '',
      publishedContentId: data['publishedContentId'] as String?,
    );
  }
}
