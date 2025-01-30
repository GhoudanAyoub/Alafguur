import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:sprintf/sprintf.dart';

import '../../../app/service/http_service.dart';
import '../page/state/root_state.dart';

class LocalizationService {
  final HttpService httpService;
  final RootState rootState;
  final defaultLanguage = 'en';

  String? _languageCode;

  Map<String, String> _translations = {};

  /// Translation language code.
  String? get languageCode => _languageCode;

  LocalizationService({
    required this.httpService,
    required this.rootState,
  });

  /// Retrieve translations for the given [locale] from the server.
  Future<LocalizationService> loadTranslations(Locale? locale) async {
    if (locale == null) {
      locale = Locale(_languageCode ?? defaultLanguage);
    }

    try {
      final response =
          (await httpService.get('i18n/${locale.languageCode}') as Map);

      _languageCode = locale.languageCode;
      httpService.apiLanguage = _languageCode;

      if (response['translations'] is Map) {
        _translations = Map.from(response['translations']);
      } else {
        _translations = {};
      }
    } catch (error, stackTrace) {
      rootState.error = error;
      rootState.stackTrace = stackTrace;
    }

    return this;
  }

  /// Return the instance of [LocalizationService] local to the given [context].
  static LocalizationService of(BuildContext context) {
    // Throw an exception if no `LocalizationService` instance is returned,
    // because the app can't function without it.
    return Localizations.of<LocalizationService>(context, LocalizationService)!;
  }

  /// Retrieve translation for the given [key] replacing [searchParams] with
  /// their counterparts from the [replaceParams] array.
  ///
  /// The [paramPlaceholderPrefix] and [paramPlaceholderSuffix] parameters
  /// define the parameter placeholder suffix and prefix respectively.
  ///
  /// If [removeHtmlTags] is `true`, all HTML tags will be removed from the
  /// translated string.
  String t(
    String key, {
    List<String> searchParams = const [],
    List<String> replaceParams = const [],
    String paramPlaceholderPrefix = '{{',
    String paramPlaceholderSuffix = '}}',
    bool removeHtmlTags = true,
  }) {
    if (!_translations.containsKey(key)) {
      return key;
    }

    if (searchParams.length != replaceParams.length) {
      throw ArgumentError(
        'searchParams and replaceParams should be of the same length',
      );
    }

    final searchParamsMap = searchParams.asMap();
    var translatedKey = _translations[key]!;

    searchParamsMap.forEach(
      (idx, param) {
        translatedKey = translatedKey.replaceAll(
          sprintf(
            '%s%s%s',
            [
              paramPlaceholderPrefix,
              param,
              paramPlaceholderSuffix,
            ],
          ),
          replaceParams[idx],
        );
      },
    );

    return removeHtmlTags ? _removeHtmlTags(translatedKey) : translatedKey;
  }

  /// remove all html tags
  String _removeHtmlTags(String translatedKey) {
    final document = parse(translatedKey);
    final parsedString = parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}
