import '../entities/course_progress.dart';
import '../entities/student_progress.dart';

abstract class ProgressRepository {
  StudentProgress getStudentProgress(String studentId, String languageCode);

  CourseProgress getCourseProgress(
    String studentId,
    String courseId,
    String languageCode,
  );
}
