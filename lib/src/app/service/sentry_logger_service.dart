import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app_settings_service.dart';
import 'browser_info_service.dart';
import 'logger_service.dart';
import 'model/logger_user_data_model.dart';

/// Sentry logger, sends messages and errors to Sentry.io.
class SentryLoggerService implements LoggerService {
  final String dsn;
  final BrowserInfoService browserInfoService;

  const SentryLoggerService({
    required this.dsn,
    required this.browserInfoService,
  });

  @override
  Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
      },
    );

    Sentry.configureScope(
      (scope) {
        // Sentry for Flutter Web doesn't collect the browser and application
        // version data by itself.
        if (kIsWeb) {
          scope.setTag('is_web', 'true');
          scope.setTag('version', AppSettingsService.release);
          scope.setTag('os.name', browserInfoService.platform);
          scope.setTag('browser', browserInfoService.browser);
          scope.setTag('engine', browserInfoService.engine);

          Sentry.configureScope(
            (scope) {
              scope.setContexts(
                'app_info',
                {
                  'build_name': AppSettingsService.buildName,
                  'release': AppSettingsService.release,
                  'bundle_id': AppSettingsService.bundleName,
                },
              );
            },
          );
        } else {
          scope.setTag('is_web', 'false');
        }
      },
    );
  }

  @override
  Future<void> logError(dynamic error, StackTrace stackTrace) {
    return Sentry.captureException(error, stackTrace: stackTrace);
  }

  @override
  Future<void> logMessage(
    String message, {
    LoggerMessageLevel level = LoggerMessageLevel.info,
  }) {
    return Sentry.captureMessage(
      message,
      level: _loggerMessageLevelToSentryLevel(level),
    );
  }

  @override
  void setUserData(LoggerUserDataModel? userData) {
    Sentry.configureScope(
      (scope) {SentryUser(
                id: userData?.id.toString(),
                username: userData?.username,
                email: userData?.email,
              );
      },
    );
  }

  /// Translate the given logger message [level] to corresponding [SentryLevel].
  SentryLevel _loggerMessageLevelToSentryLevel(LoggerMessageLevel level) {
    switch (level) {
      case LoggerMessageLevel.fatal:
        return SentryLevel.fatal;

      case LoggerMessageLevel.error:
        return SentryLevel.error;

      case LoggerMessageLevel.warning:
        return SentryLevel.warning;

      case LoggerMessageLevel.info:
        return SentryLevel.info;

      case LoggerMessageLevel.debug:
        return SentryLevel.debug;
    }
  }
}
