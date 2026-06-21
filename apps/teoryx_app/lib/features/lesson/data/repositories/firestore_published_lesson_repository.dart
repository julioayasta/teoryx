import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/firestore/firestore_collection_paths.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../models/firestore_published_lesson_model.dart';
import 'mock_lesson_repository.dart';

class FirestorePublishedLessonRepository implements LessonRepository {
  FirestorePublishedLessonRepository({
    FirebaseFirestore? firestore,
    LessonRepository? fallbackRepository,
  }) : _firestore = firestore,
       _fallbackRepository = fallbackRepository ?? const MockLessonRepository();

  final FirebaseFirestore? _firestore;
  final LessonRepository _fallbackRepository;
  List<Lesson>? _cachedLessons;

  @override
  List<Lesson> getAvailableLessons([String languageCode = 'en']) {
    return _lessonsOrFallback(languageCode);
  }

  @override
  List<Lesson> getLessonsForCourse(String courseId, String languageCode) {
    return _lessonsOrFallback(
      languageCode,
    ).where((lesson) => lesson.courseMatches(courseId)).toList();
  }

  @override
  Lesson getLessonById(String lessonId, String languageCode) {
    return _lessonsOrFallback(languageCode).firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => _fallbackRepository.getLessonById(lessonId, languageCode),
    );
  }

  @override
  Future<Lesson?> getPublishedLessonById(
    String lessonId,
    String languageCode,
  ) async {
    final cachedLessons = _cachedLessons;

    if (cachedLessons != null) {
      for (final lesson in cachedLessons) {
        if (lesson.id == lessonId && lesson.language == languageCode) {
          return lesson;
        }
      }
    }

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final doc = await firestore
          .collection(FirestoreCollectionPaths.publishedLessonContent)
          .doc(lessonId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return _fallbackRepository.getPublishedLessonById(
          lessonId,
          languageCode,
        );
      }

      final model = FirestorePublishedLessonModel.fromFirestore(
        id: doc.id,
        data: doc.data()!,
      );

      if (!model.isValid || model.language != languageCode) {
        return null;
      }

      final lesson = model.toEntity();
      _cachedLessons = [...?_cachedLessons, lesson];

      return lesson;
    } on Object {
      return _fallbackRepository.getPublishedLessonById(lessonId, languageCode);
    }
  }

  Future<List<Lesson>> preloadPublishedLessons() async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection(FirestoreCollectionPaths.publishedLessonContent)
          .get();

      final models = snapshot.docs
          .map(
            (doc) => FirestorePublishedLessonModel.fromFirestore(
              id: doc.id,
              data: doc.data(),
            ),
          )
          .toList();

      if (models.isEmpty || models.any((model) => model.hasUnsupportedSteps)) {
        _cachedLessons = null;
        return _fallbackRepository.getAvailableLessons();
      }

      final validModels = models.where((model) => model.isValid).toList();

      if (validModels.isEmpty) {
        _cachedLessons = null;
        return _fallbackRepository.getAvailableLessons();
      }

      _cachedLessons = validModels.map((model) => model.toEntity()).toList();
      return _cachedLessons!;
    } on Object {
      _cachedLessons = null;
      return _fallbackRepository.getAvailableLessons();
    }
  }

  List<Lesson> _lessonsOrFallback(String languageCode) {
    final lessons = _cachedLessons
        ?.where((lesson) => lesson.language == languageCode)
        .toList();

    if (lessons == null || lessons.isEmpty) {
      return _fallbackRepository.getAvailableLessons(languageCode);
    }

    return lessons;
  }
}

extension on Lesson {
  bool courseMatches(String courseId) {
    return switch (courseId) {
      'grade-4-math' => gradeLevelId == 'grade-4' && subjectId == 'math',
      'grade-4-ela' => gradeLevelId == 'grade-4' && subjectId == 'ela',
      'grade-5-math' => gradeLevelId == 'grade-5' && subjectId == 'math',
      'grade-5-ela' => gradeLevelId == 'grade-5' && subjectId == 'ela',
      _ => false,
    };
  }
}
