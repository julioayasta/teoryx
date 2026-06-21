import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/firestore/firestore_collection_paths.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/entities/student_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/firestore_student_progress_model.dart';
import 'mock_progress_repository.dart';

class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({
    required this.schoolId,
    required this.studentId,
    FirebaseFirestore? firestore,
    ProgressRepository? fallbackRepository,
  }) : _firestore = firestore,
       _fallbackRepository =
           fallbackRepository ?? const MockProgressRepository();

  final String schoolId;
  final String studentId;
  final FirebaseFirestore? _firestore;
  final ProgressRepository _fallbackRepository;
  StudentProgress? _cachedStudentProgress;

  Future<StudentProgress> preloadStudentProgress(String languageCode) async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .doc(
            FirestoreCollectionPaths.studentProgress(
              schoolId: schoolId,
              studentId: studentId,
            ),
          )
          .get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return _fallbackStudentProgress(languageCode);
      }

      final model = FirestoreStudentProgressModel.fromFirestore(
        id: snapshot.id,
        data: data,
      );

      if (!model.isValid) {
        return _fallbackStudentProgress(languageCode);
      }

      _cachedStudentProgress = model.toEntity();
      return _cachedStudentProgress!;
    } on Object {
      return _fallbackStudentProgress(languageCode);
    }
  }

  @override
  StudentProgress getStudentProgress(String studentId, String languageCode) {
    return _cachedStudentProgress ?? _fallbackStudentProgress(languageCode);
  }

  @override
  CourseProgress getCourseProgress(
    String studentId,
    String courseId,
    String languageCode,
  ) {
    return _fallbackRepository.getCourseProgress(
      studentId,
      courseId,
      languageCode,
    );
  }

  StudentProgress _fallbackStudentProgress(String languageCode) {
    return _fallbackRepository.getStudentProgress(studentId, languageCode);
  }
}
