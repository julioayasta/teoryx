import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/lesson_specification.dart';
import '../../domain/repositories/lesson_specification_repository.dart';
import '../models/firestore_lesson_specification_model.dart';
import 'mock_lesson_specification_repository.dart';

class FirestoreLessonSpecificationRepository
    implements LessonSpecificationRepository {
  FirestoreLessonSpecificationRepository({
    FirebaseFirestore? firestore,
    LessonSpecificationRepository? fallbackRepository,
  }) : _firestore = firestore,
       _fallbackRepository =
           fallbackRepository ?? const MockLessonSpecificationRepository();

  final FirebaseFirestore? _firestore;
  final LessonSpecificationRepository _fallbackRepository;

  @override
  Future<LessonSpecification?> getLessonSpecificationById(
    String lessonSpecificationId,
    String languageCode,
  ) async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final doc = await firestore
          .collection('lessonSpecifications')
          .doc(lessonSpecificationId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return _fallbackRepository.getLessonSpecificationById(
          lessonSpecificationId,
          languageCode,
        );
      }

      final model = FirestoreLessonSpecificationModel.fromFirestore(
        id: doc.id,
        data: doc.data()!,
      );

      if (!model.isValid || model.language != languageCode) {
        return null;
      }

      return model.toEntity();
    } on Object {
      return _fallbackRepository.getLessonSpecificationById(
        lessonSpecificationId,
        languageCode,
      );
    }
  }

  @override
  Future<List<LessonSpecification>> getLessonSpecificationsForCourse(
    String courseId,
    String languageCode,
  ) async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore.collection('lessonSpecifications').get();

      final specs =
          snapshot.docs
              .map(
                (doc) => FirestoreLessonSpecificationModel.fromFirestore(
                  id: doc.id,
                  data: doc.data(),
                ),
              )
              .where(
                (model) =>
                    model.isValid &&
                    model.courseId == courseId &&
                    model.language == languageCode,
              )
              .map((model) => model.toEntity())
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      if (specs.isEmpty) {
        return _fallbackRepository.getLessonSpecificationsForCourse(
          courseId,
          languageCode,
        );
      }

      return specs;
    } on Object {
      return _fallbackRepository.getLessonSpecificationsForCourse(
        courseId,
        languageCode,
      );
    }
  }
}
