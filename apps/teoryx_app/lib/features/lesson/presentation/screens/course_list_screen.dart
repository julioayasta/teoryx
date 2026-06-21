import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../data/repositories/mock_course_repository.dart';
import '../../data/repositories/mock_grade_level_repository.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({required this.gradeLevelId, super.key});

  final String gradeLevelId;

  static const _courseRepository = MockCourseRepository();
  static const _gradeLevelRepository = MockGradeLevelRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final gradeLevel = _gradeLevelRepository.getGradeLevelById(
      gradeLevelId,
      languageCode,
    );
    final courses = _courseRepository.getCoursesForGrade(
      gradeLevelId,
      languageCode,
    );

    return AppScaffold(
      breadcrumbs: [
        AppBreadcrumb(
          label: context.l10n.dashboardTitle,
          onTap: () => context.goNamed(RouteNames.studentDashboard),
        ),
        AppBreadcrumb(label: gradeLevel.name),
      ],
      leading: IconButton(
        tooltip: context.l10n.backToGrades,
        onPressed: () => context.goNamed(RouteNames.gradeSelection),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          tooltip: context.l10n.dashboardTitle,
          onPressed: () => context.goNamed(RouteNames.studentDashboard),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.chooseCoursePrompt,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (courses.isEmpty)
            Text(context.l10n.noCoursesForGrade)
          else
            for (final course in courses)
              Card(
                child: ListTile(
                  leading: Icon(
                    course.subjectId == 'math'
                        ? Icons.calculate_outlined
                        : Icons.menu_book_outlined,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(course.title),
                  subtitle: Text(
                    '${course.gradeLevelName} • ${course.subjectName}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(
                    RouteNames.lessonList,
                    pathParameters: {'courseId': course.id},
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
