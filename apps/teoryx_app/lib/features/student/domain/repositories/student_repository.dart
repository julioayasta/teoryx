import '../entities/student_profile.dart';

abstract class StudentRepository {
  StudentProfile getCurrentStudent();

  Future<StudentProfile?> getStudentProfile({
    required String schoolId,
    required String studentId,
  });
}
