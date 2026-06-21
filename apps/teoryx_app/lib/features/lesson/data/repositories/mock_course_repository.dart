import '../../domain/entities/course.dart';

class MockCourseRepository {
  const MockCourseRepository();

  List<Course> getAvailableCourses() {
    return const [
      Course(
        id: 'grade-4-math',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        gradeLevelName: 'Grade 4',
        subjectId: 'math',
        subjectName: 'Math',
        title: 'Grade 4 Math',
      ),
      Course(
        id: 'grade-4-ela',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        gradeLevelName: 'Grade 4',
        subjectId: 'ela',
        subjectName: 'ELA',
        title: 'Grade 4 ELA',
      ),
    ];
  }

  Course getCourseById(String courseId) {
    return getAvailableCourses().firstWhere(
      (course) => course.id == courseId,
      orElse: () => getAvailableCourses().first,
    );
  }
}
