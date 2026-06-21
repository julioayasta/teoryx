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
  }) : _firestore = firestore,
       _fallbackRepository = fallbackRepository ?? const MockCourseRepository();

  final String schoolId;
  final FirebaseFirestore? _firestore;
  final CourseRepository _fallbackRepository;
  List<Course>? _cachedCourses;

  @override
  List<Course> getEnrolledCourses(String languageCode) {
    final courses = _coursesOrFallback(languageCode);

    return courses.where((course) => course.id == 'grade-4-math').toList();
  }

  @override
  List<Course> getAvailableCourses(String languageCode) {
    return _coursesOrFallback(languageCode);
  }

  @override
  List<Course> getCoursesForGrade(String gradeLevelId, String languageCode) {
    return _coursesOrFallback(
      languageCode,
    ).where((course) => course.gradeLevelId == gradeLevelId).toList();
  }

  @override
  Course getCourseById(String courseId, String languageCode) {
    return _coursesOrFallback(languageCode).firstWhere(
      (course) => course.id == courseId,
      orElse: () => _fallbackRepository.getCourseById(courseId, languageCode),
    );
  }

  Future<List<Course>> preloadCourses() async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection(FirestoreCollectionPaths.courses(schoolId))
          .get();

      final models =
          snapshot.docs
              .map(
                (doc) => FirestoreCourseModel.fromFirestore(
                  id: doc.id,
                  data: doc.data(),
                ),
              )
              .where((model) => model.isValid)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      if (models.isEmpty) {
        _cachedCourses = null;
        return _fallbackRepository.getAvailableCourses('en');
      }

      _cachedCourses = models.map((model) => model.toEntity()).toList();
      return _cachedCourses!;
    } on Object {
      _cachedCourses = null;
      return _fallbackRepository.getAvailableCourses('en');
    }
  }

  List<Course> _coursesOrFallback(String languageCode) {
    final courses = _cachedCourses;

    if (courses == null || courses.isEmpty) {
      return _fallbackRepository.getAvailableCourses(languageCode);
    }

    return courses;
  }
}
