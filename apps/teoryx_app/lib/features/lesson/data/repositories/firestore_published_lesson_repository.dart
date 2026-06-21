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
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _fallbackRepository = fallbackRepository ?? const MockLessonRepository();

  final FirebaseFirestore _firestore;
  final LessonRepository _fallbackRepository;

  @override
  List<Lesson> getAvailableLessons([String languageCode = 'en']) {
    return _fallbackRepository.getAvailableLessons(languageCode);
  }

  @override
  List<Lesson> getLessonsForCourse(String courseId, String languageCode) {
    return _fallbackRepository.getLessonsForCourse(courseId, languageCode);
  }

  @override
  Lesson getLessonById(String lessonId, String languageCode) {
    return _fallbackRepository.getLessonById(lessonId, languageCode);
  }

  Future<List<Lesson>> getPublishedLessonsForCourseFromFirestore({
    required String courseId,
    required String languageCode,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollectionPaths.publishedLessonContent)
        .where('courseId', isEqualTo: courseId)
        .where('language', isEqualTo: languageCode)
        .where('status', isEqualTo: 'published')
        .get();

    if (snapshot.docs.isEmpty) {
      return _fallbackRepository.getLessonsForCourse(courseId, languageCode);
    }

    return snapshot.docs
        .map(
          (doc) => FirestorePublishedLessonModel.fromFirestore(
            id: doc.id,
            data: doc.data(),
          ).toEntity(),
        )
        .toList();
  }

  Future<Lesson> getPublishedLessonByIdFromFirestore({
    required String lessonId,
    required String languageCode,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollectionPaths.publishedLessonContent)
        .doc(lessonId)
        .get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return _fallbackRepository.getLessonById(lessonId, languageCode);
    }

    return FirestorePublishedLessonModel.fromFirestore(
      id: snapshot.id,
      data: data,
    ).toEntity();
  }
}
