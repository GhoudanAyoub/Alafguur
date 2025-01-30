import 'model/logger_user_data_model.dart';

/// Available message log levels.
enum LoggerMessageLevel {
  fatal,
  error,
  warning,
  info,
  debug,
}

/// All loggers available in the current version of the app.
class LoggerType {
  static const String sentry = 'sentry';
  static const String local = 'local';
}

/// Interface defining basic logger functions. Should be implemented by all
/// loggers.
abstract class LoggerService {
  /// Initialize the logger.
  Future<void> initialize();

  /// Log the given [error] and related [stackTrace].
  Future<void> logError(dynamic error, StackTrace stackTrace);

  /// Log the given [message], optionally the message log [level] can be set.
  Future<void> logMessage(
    String message, {
    LoggerMessageLevel level = LoggerMessageLevel.info,
  });

  /// Attach the provided [userData] to all subsequent log messages. Pass `null`
  /// to clear the user data.
  void setUserData(LoggerUserDataModel? userData);
}
