import 'package:equatable/equatable.dart';

class LessonSpecification extends Equatable {
  const LessonSpecification({
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
  final String? publishedContentId;

  bool get hasPublishedContent {
    final id = publishedContentId;
    return id != null && id.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    schoolId,
    courseId,
    courseOfferingId,
    title,
    order,
    language,
    generationStatus,
    estimatedDuration,
    difficultyLevel,
    publishedContentId,
  ];
}
