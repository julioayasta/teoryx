import '../../domain/entities/tutor_message.dart';

class MockTutorRepository {
  const MockTutorRepository();

  List<TutorMessage> getMessagesForLesson(String lessonId) {
    return [
      TutorMessage(
        id: 'message-1',
        lessonId: lessonId,
        author: TutorMessageAuthor.tutor,
        text:
            'Let us reason from the learning objective. A fraction names equal parts of the same whole.',
      ),
      TutorMessage(
        id: 'message-2',
        lessonId: lessonId,
        author: TutorMessageAuthor.student,
        text: 'Why does the denominator matter?',
      ),
      TutorMessage(
        id: 'message-3',
        lessonId: lessonId,
        author: TutorMessageAuthor.tutor,
        text:
            'The denominator tells how many equal parts make one whole. Larger denominators can mean smaller parts when the whole stays the same.',
      ),
    ];
  }
}
