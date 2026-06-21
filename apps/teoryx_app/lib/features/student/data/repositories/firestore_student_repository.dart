import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/firestore/firestore_collection_paths.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/firestore_student_profile_model.dart';
import 'mock_student_repository.dart';

class FirestoreStudentRepository implements StudentRepository {
  FirestoreStudentRepository({
    required this.schoolId,
    required this.studentId,
    FirebaseFirestore? firestore,
    StudentRepository? fallbackRepository,
  }) : _firestore = firestore,
       _fallbackRepository =
           fallbackRepository ?? const MockStudentRepository();

  final String schoolId;
  final String studentId;
  final FirebaseFirestore? _firestore;
  final StudentRepository _fallbackRepository;
  StudentProfile? _cachedStudentProfile;

  @override
  StudentProfile getCurrentStudent() {
    return _cachedStudentProfile ?? _fallbackRepository.getCurrentStudent();
  }

  @override
  Future<StudentProfile?> getStudentProfile({
    required String schoolId,
    required String studentId,
  }) async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .doc(
            FirestoreCollectionPaths.student(
              schoolId: schoolId,
              studentId: studentId,
            ),
          )
          .get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return _fallbackStudentProfile(
          schoolId: schoolId,
          studentId: studentId,
        );
      }

      final model = FirestoreStudentProfileModel.fromFirestore(
        id: snapshot.id,
        schoolId: schoolId,
        data: data,
      );

      if (!model.isValid) {
        return _fallbackStudentProfile(
          schoolId: schoolId,
          studentId: studentId,
        );
      }

      _cachedStudentProfile = model.toEntity();
      return _cachedStudentProfile;
    } on Object {
      return _fallbackStudentProfile(schoolId: schoolId, studentId: studentId);
    }
  }

  Future<StudentProfile?> _fallbackStudentProfile({
    required String schoolId,
    required String studentId,
  }) {
    return _fallbackRepository.getStudentProfile(
      schoolId: schoolId,
      studentId: studentId,
    );
  }
}
