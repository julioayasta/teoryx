import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

class MockCourseRepository implements CourseRepository {
  const MockCourseRepository();

  @override
  List<Course> getEnrolledCourses(String languageCode) {
    return getAvailableCourses(
      languageCode,
    ).where((course) => course.id == 'grade-4-math').toList();
  }

  @override
  List<Course> getAvailableCourses(String languageCode) {
    final isSpanish = languageCode == 'es';

    return [
      Course(
        id: 'grade-4-math',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        gradeLevelName: isSpanish ? 'Grado 4' : 'Grade 4',
        subjectId: 'math',
        subjectName: isSpanish ? 'Matematicas' : 'Math',
        title: isSpanish ? 'Grado 4 Matematicas' : 'Grade 4 Math',
      ),
      Course(
        id: 'grade-4-ela',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        gradeLevelName: isSpanish ? 'Grado 4' : 'Grade 4',
        subjectId: 'ela',
        subjectName: 'ELA',
        title: isSpanish ? 'Grado 4 ELA' : 'Grade 4 ELA',
      ),
      Course(
        id: 'grade-5-math',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-5',
        gradeLevelName: isSpanish ? 'Grado 5' : 'Grade 5',
        subjectId: 'math',
        subjectName: isSpanish ? 'Matematicas' : 'Math',
        title: isSpanish ? 'Grado 5 Matematicas' : 'Grade 5 Math',
      ),
      Course(
        id: 'grade-5-ela',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-5',
        gradeLevelName: isSpanish ? 'Grado 5' : 'Grade 5',
        subjectId: 'ela',
        subjectName: 'ELA',
        title: isSpanish ? 'Grado 5 ELA' : 'Grade 5 ELA',
      ),
    ];
  }

  @override
  List<Course> getCoursesForGrade(String gradeLevelId, String languageCode) {
    return getAvailableCourses(
      languageCode,
    ).where((course) => course.gradeLevelId == gradeLevelId).toList();
  }

  @override
  Course getCourseById(String courseId, String languageCode) {
    return getAvailableCourses(languageCode).firstWhere(
      (course) => course.id == courseId,
      orElse: () => getAvailableCourses(languageCode).first,
    );
  }
}
