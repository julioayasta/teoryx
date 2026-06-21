import '../../../../core/theme/school_theme_config.dart';

abstract class SchoolThemeRepository {
  Future<SchoolThemeConfig?> getSchoolThemeConfig(String schoolId);
}
