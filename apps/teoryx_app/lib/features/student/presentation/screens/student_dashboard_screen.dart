import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/data/repositories/mock_course_repository.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_student_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const _studentRepository = MockStudentRepository();
  static const _courseRepository = MockCourseRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final student = _studentRepository.getCurrentStudent();
    final enrolledCourses = _courseRepository.getEnrolledCourses(languageCode);

    return AppScaffold(
      title: context.l10n.dashboardTitle,
      leading: IconButton(
        tooltip: context.l10n.backToLogin,
        onPressed: () => context.goNamed(RouteNames.mockLogin),
        icon: const Icon(Icons.arrow_back),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.studentGreeting(student.firstName),
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.grade_outlined),
                label: Text(student.gradeLevelName),
              ),
              Chip(
                avatar: const Icon(Icons.calculate_outlined),
                label: Text(student.subjectName),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.continueLearningTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (enrolledCourses.isEmpty)
            Text(context.l10n.noStartedCourses)
          else
            for (final course in enrolledCourses)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(course.title),
                  subtitle: Text(context.l10n.startedCourseLabel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(
                    RouteNames.lessonList,
                    pathParameters: {'courseId': course.id},
                  ),
                ),
              ),
          const SizedBox(height: 28),
          Text(
            context.l10n.courseCatalogTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.chooseCourseFromDashboard),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.goNamed(RouteNames.gradeSelection),
            icon: const Icon(Icons.school_outlined),
            label: Text(context.l10n.chooseNewCourse),
          ),
        ],
      ),
    );
  }
}
