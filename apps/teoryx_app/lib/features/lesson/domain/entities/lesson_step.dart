import 'package:equatable/equatable.dart';

enum LessonStepType {
  story,
  imagePlaceholder,
  explanation,
  question,
  practice,
  summary,
}

class LessonStep extends Equatable {
  const LessonStep({
    required this.id,
    required this.lessonId,
    required this.order,
    required this.type,
    required this.title,
    required this.body,
    this.prompt,
    this.expectedAnswer,
    this.imageDescription,
  });

  final String id;
  final String lessonId;
  final int order;
  final LessonStepType type;
  final String title;
  final String body;
  final String? prompt;
  final String? expectedAnswer;
  final String? imageDescription;

  @override
  List<Object?> get props => [
        id,
        lessonId,
        order,
        type,
        title,
        body,
        prompt,
        expectedAnswer,
        imageDescription,
      ];
}
