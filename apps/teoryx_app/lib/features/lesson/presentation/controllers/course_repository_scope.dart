import 'package:flutter/widgets.dart';

import '../../domain/repositories/course_repository.dart';

class CourseRepositoryScope extends InheritedWidget {
  const CourseRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final CourseRepository repository;

  static CourseRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CourseRepositoryScope>();
    assert(scope != null, 'CourseRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(CourseRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
