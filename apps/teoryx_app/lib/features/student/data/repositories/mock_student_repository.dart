import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';

class MockStudentRepository implements StudentRepository {
  const MockStudentRepository();

  @override
  StudentProfile getCurrentStudent() {
    return const StudentProfile(
      id: 'student-001',
      schoolId: 'school-demo',
      firstName: 'Sofia',
      gradeLevelName: 'Grade 4',
      subjectName: 'Math',
      preferredLanguage: 'en',
    );
  }

  @override
  Future<StudentProfile?> getStudentProfile({
    required String schoolId,
    required String studentId,
  }) async {
    final student = getCurrentStudent();

    if (student.schoolId == schoolId && student.id == studentId) {
      return student;
    }

    return null;
  }
}
