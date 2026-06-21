import 'package:equatable/equatable.dart';

class ProgressRecommendation extends Equatable {
  const ProgressRecommendation({
    required this.title,
    required this.message,
    required this.recommendedLessonId,
    required this.recommendedActionLabel,
  });

  final String title;
  final String message;
  final String recommendedLessonId;
  final String recommendedActionLabel;

  @override
  List<Object?> get props => [
    title,
    message,
    recommendedLessonId,
    recommendedActionLabel,
  ];
}
