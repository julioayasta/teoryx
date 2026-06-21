import '../../domain/entities/course.dart';

class FirestoreCourseModel {
  const FirestoreCourseModel({
    required this.id,
    required this.curriculumId,
    required this.gradeLevelId,
    required this.gradeLevelName,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.status,
    required this.order,
  });

  final String id;
  final String curriculumId;
  final String gradeLevelId;
  final String gradeLevelName;
  final String subjectId;
  final String subjectName;
  final String title;
  final String status;
  final int order;

  bool get isValid {
    return id.isNotEmpty &&
        curriculumId.isNotEmpty &&
        gradeLevelId.isNotEmpty &&
        gradeLevelName.isNotEmpty &&
        subjectId.isNotEmpty &&
        subjectName.isNotEmpty &&
        title.isNotEmpty &&
        (status == 'active' || status == 'published');
  }

  Course toEntity() {
    return Course(
      id: id,
      curriculumId: curriculumId,
      gradeLevelId: gradeLevelId,
      gradeLevelName: gradeLevelName,
      subjectId: subjectId,
      subjectName: subjectName,
      title: title,
    );
  }

  static FirestoreCourseModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FirestoreCourseModel(
      id: data['courseId'] as String? ?? id,
      curriculumId: data['curriculumId'] as String? ?? '',
      gradeLevelId: data['gradeLevelId'] as String? ?? '',
      gradeLevelName: data['gradeLevelName'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      order: data['order'] is int ? data['order'] as int : 0,
    );
  }
}
