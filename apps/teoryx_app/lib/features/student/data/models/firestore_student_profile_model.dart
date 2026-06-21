import '../../domain/entities/student_profile.dart';

class FirestoreStudentProfileModel {
  const FirestoreStudentProfileModel({
    required this.id,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    required this.gradeLevelId,
    required this.gradeLevelName,
    required this.preferredLanguage,
    required this.status,
  });

  final String id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String gradeLevelId;
  final String gradeLevelName;
  final String preferredLanguage;
  final String status;

  bool get isValid {
    return id.isNotEmpty &&
        schoolId.isNotEmpty &&
        firstName.isNotEmpty &&
        gradeLevelId.isNotEmpty &&
        gradeLevelName.isNotEmpty &&
        status == 'active';
  }

  StudentProfile toEntity() {
    return StudentProfile(
      id: id,
      schoolId: schoolId,
      firstName: firstName,
      gradeLevelName: gradeLevelName,
      subjectName: '',
      preferredLanguage: preferredLanguage,
    );
  }

  static FirestoreStudentProfileModel fromFirestore({
    required String id,
    required String schoolId,
    required Map<String, dynamic> data,
  }) {
    return FirestoreStudentProfileModel(
      id: data['studentId'] as String? ?? id,
      schoolId: schoolId,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      gradeLevelId: data['gradeLevelId'] as String? ?? '',
      gradeLevelName: data['gradeLevelName'] as String? ?? '',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      status: data['status'] as String? ?? 'active',
    );
  }
}
