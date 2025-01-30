import 'package:flutter/material.dart';

import '../service/localization_service.dart';

class LocalizationDelegate extends LocalizationsDelegate<LocalizationService> {
  final LocalizationService localizationService;

  LocalizationDelegate({
    required this.localizationService,
  });

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<LocalizationService> load(Locale locale) =>
      localizationService.loadTranslations(locale);

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
