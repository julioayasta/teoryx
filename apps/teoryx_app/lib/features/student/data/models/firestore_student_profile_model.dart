import '../../domain/entities/student_profile.dart';

class FirestoreStudentProfileModel {
  const FirestoreStudentProfileModel({
    required this.id,
    required this.schoolId,
    required this.firstName,
    required this.gradeLevelName,
    required this.subjectName,
    required this.preferredLanguage,
  });

  final String id;
  final String schoolId;
  final String firstName;
  final String gradeLevelName;
  final String subjectName;
  final String preferredLanguage;

  StudentProfile toEntity() {
    return StudentProfile(
      id: id,
      schoolId: schoolId,
      firstName: firstName,
      gradeLevelName: gradeLevelName,
      subjectName: subjectName,
      preferredLanguage: preferredLanguage,
    );
  }

  static FirestoreStudentProfileModel fromFirestore({
    required String id,
    required String schoolId,
    required Map<String, dynamic> data,
  }) {
    return FirestoreStudentProfileModel(
      id: id,
      schoolId: schoolId,
      firstName: data['firstName'] as String? ?? '',
      gradeLevelName: data['gradeLevelName'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
    );
  }
}
