import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.curriculumId,
    required this.gradeLevelId,
    required this.gradeLevelName,
    required this.subjectId,
    required this.subjectName,
    required this.title,
  });

  final String id;
  final String curriculumId;
  final String gradeLevelId;
  final String gradeLevelName;
  final String subjectId;
  final String subjectName;
  final String title;

  @override
  List<Object?> get props => [
    id,
    curriculumId,
    gradeLevelId,
    gradeLevelName,
    subjectId,
    subjectName,
    title,
  ];
}
