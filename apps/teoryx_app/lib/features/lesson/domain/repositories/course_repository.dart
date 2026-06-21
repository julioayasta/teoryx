import '../entities/course.dart';

abstract class CourseRepository {
  List<Course> getEnrolledCourses(String languageCode);

  List<Course> getAvailableCourses(String languageCode);

  List<Course> getCoursesForGrade(String gradeLevelId, String languageCode);

  Course getCourseById(String courseId, String languageCode);
}
