import 'package:flutter/widgets.dart';

import '../../domain/repositories/student_repository.dart';

class StudentRepositoryScope extends InheritedWidget {
  const StudentRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final StudentRepository repository;

  static StudentRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StudentRepositoryScope>();
    assert(scope != null, 'StudentRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(StudentRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
