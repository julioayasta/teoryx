import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_course_repository.dart';

class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  static const _courseRepository = MockCourseRepository();

  @override
  Widget build(BuildContext context) {
    final courses = _courseRepository.getAvailableCourses();

    return AppScaffold(
      title: context.l10n.courseSelectionTitle,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            onPressed: () => context.goNamed(RouteNames.studentDashboard),
            icon: const Icon(Icons.arrow_back),
            label: Text(context.l10n.backToDashboard),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.chooseCoursePrompt,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
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
