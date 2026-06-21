import 'package:flutter/widgets.dart';

import '../../domain/repositories/progress_repository.dart';

class ProgressRepositoryScope extends InheritedWidget {
  const ProgressRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final ProgressRepository repository;

  static ProgressRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProgressRepositoryScope>();
    assert(scope != null, 'ProgressRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(ProgressRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
