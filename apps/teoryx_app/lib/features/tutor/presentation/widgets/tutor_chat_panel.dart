import 'package:flutter/material.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../data/repositories/mock_tutor_repository.dart';
import '../../domain/entities/tutor_message.dart';

class TutorChatPanel extends StatelessWidget {
  const TutorChatPanel({required this.lessonId, super.key});

  final String lessonId;

  static const _tutorRepository = MockTutorRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final messages = _tutorRepository.getMessagesForLesson(
      lessonId,
      languageCode,
    );

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.tutorChatTitle,
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.closeTutorChat,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colorScheme.outlineVariant),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  return _TutorMessageBubble(message: messages[index]);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: messages.length,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: context.l10n.mockTutorInputHint,
                  suffixIcon: const Icon(Icons.send_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
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
            color: isStudent
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
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
