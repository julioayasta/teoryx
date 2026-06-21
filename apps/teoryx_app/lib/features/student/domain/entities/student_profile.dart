import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
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

  @override
  List<Object?> get props => [
    id,
    schoolId,
    firstName,
    gradeLevelName,
    subjectName,
    preferredLanguage,
  ];
}
