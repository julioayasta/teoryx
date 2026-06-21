import 'package:flutter/widgets.dart';

import '../../domain/repositories/content_generation_repository.dart';

class ContentGenerationRepositoryScope extends InheritedWidget {
  const ContentGenerationRepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final ContentGenerationRepository repository;

  static ContentGenerationRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ContentGenerationRepositoryScope>();
    assert(scope != null, 'ContentGenerationRepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(ContentGenerationRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
