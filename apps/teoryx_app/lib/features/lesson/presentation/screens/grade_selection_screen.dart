import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/mock_grade_level_repository.dart';

class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  static const _gradeLevelRepository = MockGradeLevelRepository();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final gradeLevels = _gradeLevelRepository.getGradeLevels(languageCode);

    return AppScaffold(
      title: context.l10n.gradeSelectionTitle,
      leading: IconButton(
        tooltip: context.l10n.backToDashboard,
        onPressed: () => context.goNamed(RouteNames.studentDashboard),
        icon: const Icon(Icons.arrow_back),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.chooseGradePrompt,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final gradeLevel in gradeLevels)
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.grade_outlined,
                  color: context.colorScheme.primary,
                ),
                title: Text(gradeLevel.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.goNamed(
                  RouteNames.courseList,
                  pathParameters: {'gradeLevelId': gradeLevel.id},
                ),
              ),
            ),
        ],
      ),
    );
  }
}
