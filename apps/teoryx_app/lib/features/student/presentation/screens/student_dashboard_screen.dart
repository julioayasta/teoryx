import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_student_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const _studentRepository = MockStudentRepository();

  @override
  Widget build(BuildContext context) {
    final student = _studentRepository.getCurrentStudent();

    return AppScaffold(
      title: context.l10n.dashboardTitle,
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
            context.l10n.readyToLearnTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.chooseCourseFromDashboard),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.goNamed(RouteNames.courseSelection),
            icon: const Icon(Icons.school_outlined),
            label: Text(context.l10n.chooseCourse),
          ),
        ],
      ),
    );
  }
}
