import 'package:flutter/widgets.dart';

import '../core/localization/app_locale_controller.dart';
import '../core/theme/school_theme_config.dart';
import 'teoryx_app.dart';

Widget buildTeoryXApp() {
  return TeoryXApp(
    localeController: AppLocaleController(),
    schoolThemeConfig: SchoolThemeConfig.k2s(),
  );
}
