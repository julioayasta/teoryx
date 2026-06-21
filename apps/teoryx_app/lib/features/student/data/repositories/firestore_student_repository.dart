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
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _fallbackRepository =
           fallbackRepository ?? const MockStudentRepository();

  final String schoolId;
  final String studentId;
  final FirebaseFirestore _firestore;
  final StudentRepository _fallbackRepository;

  @override
  StudentProfile getCurrentStudent() {
    return _fallbackRepository.getCurrentStudent();
  }

  @override
  Future<StudentProfile?> getStudentProfile({
    required String schoolId,
    required String studentId,
  }) async {
    final snapshot = await _firestore
        .doc(
          FirestoreCollectionPaths.student(
            schoolId: schoolId,
            studentId: studentId,
          ),
        )
        .get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return _fallbackRepository.getStudentProfile(
        schoolId: schoolId,
        studentId: studentId,
      );
    }

    return FirestoreStudentProfileModel.fromFirestore(
      id: snapshot.id,
      schoolId: schoolId,
      data: data,
    ).toEntity();
  }
}
