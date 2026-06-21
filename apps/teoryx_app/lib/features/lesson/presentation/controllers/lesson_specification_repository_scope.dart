import 'package:flutter/widgets.dart';

import '../../domain/repositories/lesson_specification_repository.dart';

class LessonSpecificationRepositoryScope extends InheritedWidget {
  const LessonSpecificationRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final LessonSpecificationRepository repository;

  static LessonSpecificationRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<
          LessonSpecificationRepositoryScope
        >();
    assert(scope != null, 'LessonSpecificationRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(LessonSpecificationRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
