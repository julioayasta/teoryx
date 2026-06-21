import '../../domain/entities/grade_level.dart';

class MockGradeLevelRepository {
  const MockGradeLevelRepository();

  List<GradeLevel> getGradeLevels(String languageCode) {
    final kindergartenName = languageCode == 'es' ? 'Kinder' : 'K';

    return [
      GradeLevel(id: 'kindergarten', code: 'k', name: kindergartenName),
      for (var grade = 1; grade <= 12; grade++)
        GradeLevel(
          id: 'grade-$grade',
          code: 'grade-$grade',
          name: languageCode == 'es' ? 'Grado $grade' : 'Grade $grade',
        ),
    ];
  }

  GradeLevel getGradeLevelById(String gradeLevelId, String languageCode) {
    return getGradeLevels(languageCode).firstWhere(
      (gradeLevel) => gradeLevel.id == gradeLevelId,
      orElse: () => getGradeLevels(languageCode).first,
    );
  }
}
