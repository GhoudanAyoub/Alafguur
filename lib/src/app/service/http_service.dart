import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:browser_detector/browser_detector.dart';

import '../exception/http/complete_account_exception.dart';
import '../exception/http/complete_profile_exception.dart';
import '../exception/http/disapproved_exception.dart';
import '../exception/http/email_not_verified_exception.dart';
import '../exception/http/maintenance_exception.dart';
import '../exception/http/no_internet_exception.dart';
import '../exception/http/not_found_exception.dart';
import '../exception/http/phone_code_not_verified_exception.dart';
import '../exception/http/phone_number_not_verified_exception.dart';
import '../exception/http/server_exception.dart';
import '../exception/http/suspended_exception.dart';
import '../exception/http/unauthorized_exception.dart';
import '../utility/http_api_error_utility.dart';
import 'auth_service.dart';
import 'random_service.dart';

const SERVER_UPDATES_REQUEST_NAME = 'server_updates';

class _HttpCancelToken {
  final int? id;
  final String name;
  final CancelToken token;

  _HttpCancelToken({
    required this.id,
    required this.name,
    required this.token,
  });
}

class HttpService {
  final Dio dio;
  final AuthService authService;
  final RandomService randomService;
  final BrowserDetector browserDetector;

  /// active api language
  String? apiLanguage;

  List<_HttpCancelToken> _cancelTokens = [];

  HttpService({
    required this.dio,
    required this.authService,
    required this.randomService,
    required this.browserDetector,
  });

  /// cancel any request (GET,POST, etc) by its name if it exists
  void cancelRequestByName(
    String? requestName, {
    bool useDelay = true,
  }) {
    final List<int?> removedRequests = [];

    _cancelTokens.forEach((httpCancelToken) {
      if (httpCancelToken.name == requestName) {
        removedRequests.add(httpCancelToken.id);
        if (useDelay) {
          Future.delayed(const Duration(milliseconds: 100), () {
            httpCancelToken.token.cancel(requestName);
          });
        } else {
          httpCancelToken.token.cancel(requestName);
        }
      }
    });

    // clean the cancel tokens
    if (removedRequests.isNotEmpty) {
      _cancelTokens.removeWhere(
          (httpCancelToken) => removedRequests.contains(httpCancelToken.id));
    }
  }

  /// Cancel all currently pending HTTP requests. Cancellation [reason] can be
  /// optionally provided.
  void cancelAllRequests({String? reason}) {
    final List<int?> cancelledRequests = [];

    _cancelTokens.forEach(
      (cancelToken) {
        try {
          cancelToken.token.cancel(reason);
          cancelledRequests.add(cancelToken.id);
        } catch (_) {
          // Do nothing.
        }
      },
    );

    if (cancelledRequests.isNotEmpty) {
      _cancelTokens = _cancelTokens
          .where((cancelToken) => !cancelledRequests.contains(cancelToken.id))
          .toList();
    }
  }

  /// Perform a `post` query
  Future<dynamic> post(
    String uri, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    List<MultipartFile>? files,
    ResponseType responseType = ResponseType.json,
    ProgressCallback? onSendProgressCallback,
    ProgressCallback? onReceiveProgressCallback,
    String? requestName,
  }) async {
    final requestId = requestName != null ? randomService.integer() : null;
    final response = await _postRaw(
      uri,
      data: data,
      queryParameters: queryParameters,
      files: files,
      responseType: responseType,
      onSendProgressCallback: onSendProgressCallback,
      onReceiveProgressCallback: onReceiveProgressCallback,
      requestName: requestName,
      requestId: requestId,
    );

    return response?.data;
  }

  /// Perform a `put` query
  Future<dynamic> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
  }) async {
    final requestId = requestName != null ? randomService.integer() : null;
    final response = await _putRaw(
      uri,
      data: data,
      queryParameters: queryParameters,
      responseType: responseType,
      requestName: requestName,
      requestId: requestId,
    );

    return response?.data;
  }

  /// Perform a `delete` query
  Future<dynamic> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
  }) async {
    final requestId = requestName != null ? randomService.integer() : null;
    final response = await _deleteRaw(
      uri,
      data: data,
      queryParameters: queryParameters,
      responseType: responseType,
      requestName: requestName,
      requestId: requestId,
    );

    return response?.data;
  }

  /// Perform a `get` query
  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
  }) async {
    final requestId = requestName != null ? randomService.integer() : null;
    final response = await _getRaw(
      uri,
      queryParameters: queryParameters,
      responseType: responseType,
      requestName: requestName,
      requestId: requestId,
    );

    return response?.data;
  }

  /// Send an HTTP POST request to the given [uri] containing the given [data]
  /// and/or any [files] to upload and return the [Response] object. Either
  /// [data] or [files] or both should be present for the request to be
  /// successful.
  ///
  /// Optionally attach any [queryParameters] to the resulting URL.
  ///
  /// The returned response will be of the given [responseType].
  ///
  /// Upload progress can be tracked using the [onSendProgressCallback] callback.
  ///
  /// Download progress can be tracked using the [onReceiveProgressCallback] callback.
  Future<Response?> _postRaw(
    String uri, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    List<MultipartFile>? files,
    ResponseType responseType = ResponseType.json,
    ProgressCallback? onSendProgressCallback,
    ProgressCallback? onReceiveProgressCallback,
    String? requestName,
    int? requestId,
  }) async {
    // prepare the request body
    dynamic requestData = files != null
        ? _buildFileRequestData(data, files: files) // send files
        : data;

    try {
      final response = await dio.post(
        uri,
        cancelToken: _generateCancelToken(requestName, requestId),
        queryParameters: queryParameters,
        data: requestData,
        options: Options(
          responseType: responseType,
          headers: getHeaders(),
        ),
        onSendProgress: onSendProgressCallback,
        onReceiveProgress: onReceiveProgressCallback,
      );

      _cleanCancelToken(requestId);

      return response;
    } on DioException catch (e) {
      _cleanCancelToken(requestId);

      await _triggerException(e, requestName);
    } catch (error) {
      _cleanCancelToken(requestId);
    }

    return null;
  }

  /// Send an HTTP PUT request to the given [uri] containing the given [data]
  ///
  /// Optionally attach any [queryParameters] to the resulting URL.
  ///
  /// The returned response will be of the given [responseType].
  Future<Response?> _putRaw(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
    int? requestId,
  }) async {
    try {
      final response = await dio.put(
        uri,
        cancelToken: _generateCancelToken(requestName, requestId),
        queryParameters: queryParameters,
        data: data,
        options: Options(
          responseType: responseType,
          headers: getHeaders(),
        ),
      );

      _cleanCancelToken(requestId);

      return response;
    } on DioException catch (e) {
      _cleanCancelToken(requestId);

      await _triggerException(e, requestName);
    } catch (error) {
      _cleanCancelToken(requestId);
    }

    return null;
  }

  /// Send an HTTP DELETE request to the given [uri] containing the given [data]
  ///
  /// Optionally attach any [queryParameters] to the resulting URL.
  ///
  /// The returned response will be of the given [responseType].
  Future<Response?> _deleteRaw(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
    int? requestId,
  }) async {
    try {
      final response = await dio.delete(
        uri,
        cancelToken: _generateCancelToken(requestName, requestId),
        queryParameters: queryParameters,
        data: data,
        options: Options(
          responseType: responseType,
          headers: getHeaders(),
        ),
      );

      _cleanCancelToken(requestId);

      return response;
    } on DioException catch (e) {
      _cleanCancelToken(requestId);

      await _triggerException(e, requestName);
    } catch (error) {
      _cleanCancelToken(requestId);
    }

    return null;
  }

  /// Send an HTTP GET request to the given [uri] and return the [Response]
  /// object. Optionally attach any [queryParameters] to the resulting URL.
  ///
  /// The returned response will be of the given [responseType].
  Future<Response?> _getRaw(
    String uri, {
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    String? requestName,
    int? requestId,
  }) async {
    try {
      final response = await dio.get(
        uri,
        cancelToken: _generateCancelToken(requestName, requestId),
        queryParameters: queryParameters,
        options: Options(
          responseType: responseType,
          headers: getHeaders(),
        ),
      );

      _cleanCancelToken(requestId);

      return response;
    } on DioException catch (e) {
      _cleanCancelToken(requestId);

      await _triggerException(e, requestName);
    } catch (error) {
      _cleanCancelToken(requestId);
    }

    return null;
  }

  /// get request headers
  Map<String, dynamic> getHeaders() {
    return {
      ...authService.isAuthenticated
          ? {
              'jwt': 'Bearer ' + authService.authToken!,
            }
          : {},
      ...apiLanguage != null
          ? {
              'api-language': apiLanguage,
            }
          : {},
      // append native-only headers
      ..._getNativeHeaders(),
    };
  }

  /// Convert [data] to a [FormData] instance.
  ///
  /// If [files] are set, add files to the form data. If there is only one file,
  /// it will be added to the [singularFileFieldName] field; if there are
  /// multiple files, they will be added as a [List] to the
  /// [multipleFilesFieldName] field.
  FormData _buildFileRequestData(
    Map<String, dynamic>? data, {
    List<MultipartFile>? files,
    String singularFileFieldName = 'file',
    String multipleFilesFieldName = 'files',
  }) {
    final formDataMap = {
      ...data ?? {},
    };

    if (files != null && files.isNotEmpty) {
      if (files.length > 1) {
        formDataMap[multipleFilesFieldName] = files;
      } else {
        formDataMap[singularFileFieldName] = files.first;
      }
    }

    return FormData.fromMap(formDataMap);
  }

  /// Throw a clean [ServerException] not wrapped into a [DioException]
  Future<void> _triggerException(
    DioException error,
    String? requestName,
  ) async {
    // we should not trigger errors for a user canceled requests
    if (requestName != null && error.type == DioExceptionType.cancel) {
      return;
    }

    final Response? response = error.response;

    try {
      // make sure we are still online
      await dio.get(
        'check-api',
        options: Options(
          responseType: ResponseType.json,
          headers: getHeaders(),
        ),
      );
    } catch (error) {
      throw NoInternetException(response);
    }

    if (response == null) {
      /// Don't trigger errors for server updates (Safari only)
      /// if error response is empty, fix PWA in inactive phone mode
      if (requestName == SERVER_UPDATES_REQUEST_NAME
              && kIsWeb && this.browserDetector.browser.isSafari) {

        return;
      }

      throw ServerException(response);
    }

    final String? errorType =
        response.data is Map && response.data['type'] != null
            ? response.data['type'] as String?
            : null;

    switch (response.statusCode) {
      case HttpStatus.unauthorized:
        throw UnauthorizedException(response);

      case HttpStatus.notFound:
        throw NotFoundException(response);

      case HttpStatus.forbidden:
        switch (errorType) {
          case HttpApiErrorUtility.maintenance:
            throw MaintenanceException(response);

          case HttpApiErrorUtility.suspended:
            throw SuspendedException(response);

          case HttpApiErrorUtility.disapproved:
            throw DisapprovedException(response);

          case HttpApiErrorUtility.phoneNumberNotVerified:
            throw PhoneNumberNotVerifiedException(response);

          case HttpApiErrorUtility.phoneCodeNotVerified:
            throw PhoneCodeNotVerifiedException(response);

          case HttpApiErrorUtility.emailNotVerified:
            throw EmailNotVerifiedException(response);

          case HttpApiErrorUtility.profileNotCompleted:
            throw CompleteProfileException(response);

          case HttpApiErrorUtility.accountTypeNotCompleted:
            throw CompleteAccountException(response);
        }
    }

    throw ServerException(response);
  }

  /// Generate cancellation token identified by [requestName].
  CancelToken? _generateCancelToken(
    String? requestName,
    int? requestId,
  ) {
    if (requestName != null) {
      final token = CancelToken();
      _cancelTokens.add(_HttpCancelToken(
        id: requestId,
        name: requestName,
        token: token,
      ));

      return token;
    }

    return null;
  }

  /// Returns a [Map] of native-only HTTP headers to be used with API requests
  /// if the application is running natively. Otherwise, returns an empty [Map].
  Map<String, dynamic> _getNativeHeaders() {
    return !kIsWeb
        ? {
            'user-agent': 'application',
          }
        : {};
  }

  void _cleanCancelToken(int? requestId) {
    if (requestId != null) {
      _cancelTokens
          .removeWhere((httpCancelToken) => httpCancelToken.id == requestId);
    }
  }
}
