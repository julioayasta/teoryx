import 'package:flutter/widgets.dart';

import '../../domain/repositories/lesson_repository.dart';

class LessonRepositoryScope extends InheritedWidget {
  const LessonRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final LessonRepository repository;

  static LessonRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LessonRepositoryScope>();
    assert(scope != null, 'LessonRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(LessonRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
