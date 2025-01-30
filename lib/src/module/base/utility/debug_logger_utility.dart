import '../../../app/service/app_settings_service.dart';

/// Utility to log messages to the console in debug mode.
class DebugLoggerUtility {
  /// Log [message] to the console if debug mode is enabled.
  void log(bool isSiteDebugEnabled, dynamic message) {
    if (isSiteDebugEnabled || AppSettingsService.debugMode) {
      print(message);
    }
  }
}
