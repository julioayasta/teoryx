import 'package:flutter/material.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_tutor_repository.dart';
import '../../domain/entities/tutor_message.dart';

class TutorChatScreen extends StatelessWidget {
  const TutorChatScreen({
    required this.lessonId,
    super.key,
  });

  final String lessonId;

  static const _tutorRepository = MockTutorRepository();

  @override
  Widget build(BuildContext context) {
    final messages = _tutorRepository.getMessagesForLesson(lessonId);

    return AppScaffold(
      title: context.l10n.tutorChatTitle,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                return _TutorMessageBubble(message: messages[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: messages.length,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: context.l10n.mockTutorInputHint,
                  suffixIcon: const Icon(Icons.send_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorMessageBubble extends StatelessWidget {
  const _TutorMessageBubble({required this.message});

  final TutorMessage message;

  @override
  Widget build(BuildContext context) {
    final isStudent = message.author == TutorMessageAuthor.student;
    final colorScheme = context.colorScheme;

    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isStudent ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(message.text),
          ),
        ),
      ),
    );
  }
}
