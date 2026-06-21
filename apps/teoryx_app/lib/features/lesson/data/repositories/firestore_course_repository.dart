import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/firestore/firestore_collection_paths.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/firestore_course_model.dart';
import 'mock_course_repository.dart';

class FirestoreCourseRepository implements CourseRepository {
  FirestoreCourseRepository({
    required this.schoolId,
    FirebaseFirestore? firestore,
    CourseRepository? fallbackRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _fallbackRepository = fallbackRepository ?? const MockCourseRepository();

  final String schoolId;
  final FirebaseFirestore _firestore;
  final CourseRepository _fallbackRepository;

  @override
  List<Course> getEnrolledCourses(String languageCode) {
    return _fallbackRepository.getEnrolledCourses(languageCode);
  }

  @override
  List<Course> getAvailableCourses(String languageCode) {
    return _fallbackRepository.getAvailableCourses(languageCode);
  }

  @override
  List<Course> getCoursesForGrade(String gradeLevelId, String languageCode) {
    return _fallbackRepository.getCoursesForGrade(gradeLevelId, languageCode);
  }

  @override
  Course getCourseById(String courseId, String languageCode) {
    return _fallbackRepository.getCourseById(courseId, languageCode);
  }

  Future<List<Course>> getAvailableCoursesFromFirestore() async {
    final snapshot = await _firestore
        .collection(FirestoreCollectionPaths.courses(schoolId))
        .where('status', isEqualTo: 'published')
        .get();

    if (snapshot.docs.isEmpty) {
      return const MockCourseRepository().getAvailableCourses('en');
    }

    return snapshot.docs
        .map(
          (doc) => FirestoreCourseModel.fromFirestore(
            id: doc.id,
            data: doc.data(),
          ).toEntity(),
        )
        .toList();
  }
}
