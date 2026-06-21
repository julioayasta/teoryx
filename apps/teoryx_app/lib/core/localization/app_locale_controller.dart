import 'package:flutter/widgets.dart';

import '../constants/supported_locales.dart';

class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController() : super(SupportedLocales.english);

  void setLocale(Locale locale) {
    if (SupportedLocales.values.contains(locale)) {
      value = locale;
    }
  }
}
