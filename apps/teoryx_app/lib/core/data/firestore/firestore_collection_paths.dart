class FirestoreCollectionPaths {
  const FirestoreCollectionPaths._();

  static String school(String schoolId) => 'schools/$schoolId';

  static String student({required String schoolId, required String studentId}) {
    return 'schools/$schoolId/students/$studentId';
  }

  static String courses(String schoolId) => 'schools/$schoolId/courses';

  static String course({required String schoolId, required String courseId}) {
    return '${courses(schoolId)}/$courseId';
  }

  static String studentProgress({
    required String schoolId,
    required String studentId,
  }) {
    return 'schools/$schoolId/studentProgress/$studentId';
  }

  static const publishedLessonContent = 'publishedLessonContent';
}
