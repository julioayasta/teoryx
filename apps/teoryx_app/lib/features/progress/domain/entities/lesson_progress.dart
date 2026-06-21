import 'package:equatable/equatable.dart';

import 'student_progress.dart';

class LessonProgress extends Equatable {
  const LessonProgress({
    required this.lessonId,
    required this.lessonTitle,
    required this.status,
    required this.masteryLevel,
  });

  final String lessonId;
  final String lessonTitle;
  final LessonProgressStatus status;
  final MasteryLevel masteryLevel;

  @override
  List<Object?> get props => [lessonId, lessonTitle, status, masteryLevel];
}
