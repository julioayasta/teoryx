import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../features/lesson/data/repositories/mock_lesson_repository.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_student_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const _studentRepository = MockStudentRepository();
  static const _lessonRepository = MockLessonRepository();

  @override
  Widget build(BuildContext context) {
    final student = _studentRepository.getCurrentStudent();
    final lessons = _lessonRepository.getAvailableLessons();

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
            context.l10n.availableLessonsTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final lesson in lessons.take(2))
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.menu_book_outlined,
                  color: context.colorScheme.primary,
                ),
                title: Text(lesson.title),
                subtitle: Text(lesson.standardCode),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.goNamed(
                  RouteNames.lessonDetail,
                  pathParameters: {'lessonId': lesson.id},
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.goNamed(RouteNames.lessonList),
            icon: const Icon(Icons.list_alt_outlined),
            label: Text(context.l10n.viewAllLessons),
          ),
        ],
      ),
    );
  }
}
