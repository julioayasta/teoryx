import '../../domain/entities/student_profile.dart';

class MockStudentRepository {
  const MockStudentRepository();

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
}
