import '../exception/http/server_exception.dart';
import 'device_info_service.dart';
import 'http_service.dart';
import 'logger_service.dart';
import 'model/logger_user_data_model.dart';

/// Local logger, sends messages and errors to the app backend.
class LocalLoggerService implements LoggerService {
  final HttpService httpService;
  final DeviceInfoService deviceInfoService;

  LoggerUserDataModel? _userData;

  LocalLoggerService({
    required this.httpService,
    required this.deviceInfoService,
  });

  @override
  Future<void> initialize() {
    return Future.value();
  }

  @override
  Future<void> logError(dynamic error, StackTrace stackTrace) async {
    return httpService.post(
      'logs',
      data: await _createErrorRequestBody(error, stackTrace),
    );
  }

  @override
  Future<void> logMessage(
    String message, {
    LoggerMessageLevel level = LoggerMessageLevel.info,
  }) async {
    return httpService.post(
      'logs',
      data: await _createMessageRequestBody(message),
    );
  }

  @override
  void setUserData(LoggerUserDataModel? userData) {
    _userData = userData;
  }

  Future<Map<String, dynamic>> _createMessageRequestBody(String message) async {
    return {
      'message': message,
      ...await _createBasicRequestBody(),
    };
  }

  Future<Map<String, dynamic>> _createErrorRequestBody(
    dynamic error,
    StackTrace stackTrace,
  ) async {
    var result = <String, dynamic>{
      'message': error.toString(),
      'stackTrace': stackTrace.toString(),
    };

    if (error is ServerException) {
      result = {
        ...result,
        'isServerException': true,
      };

      if (error.response != null) {
        final response = error.response!;

        result = {
          ...result,
          'isResponseInfoAvailable': true,
          'isRedirect': response.isRedirect,
          'statusCode': response.statusCode,
          'statusMessage': response.statusMessage,
          'requestMethod': response.requestOptions.method,
          'requestUri': response.requestOptions.uri.toString(),
          'responseBody': response.data.toString(),
        };
      }
    }

    return {
      ...result,
      ...await _createBasicRequestBody(),
    };
  }

  Future<Map<String, dynamic>> _createBasicRequestBody() async {
    return {
      'userId': _userData?.id,
      'userName': _userData?.username,
      'userEmail': _userData?.email,
      'platformInfo': await deviceInfoService.getDeviceInfoMap(),
    };
  }
}
