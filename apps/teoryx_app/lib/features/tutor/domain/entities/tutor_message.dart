import 'package:equatable/equatable.dart';

enum TutorMessageAuthor {
  student,
  tutor,
}

class TutorMessage extends Equatable {
  const TutorMessage({
    required this.id,
    required this.lessonId,
    required this.author,
    required this.text,
  });

  final String id;
  final String lessonId;
  final TutorMessageAuthor author;
  final String text;

  @override
  List<Object?> get props => [id, lessonId, author, text];
}
