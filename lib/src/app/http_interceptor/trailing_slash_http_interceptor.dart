import 'package:dio/dio.dart';

class TrailingSlashHttpInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // add a trailing slash to the end of each request if there's none
    if (!options.path.endsWith('/')) {
      options.path = options.path + '/';
    }

    return handler.next(options);
  }
}
