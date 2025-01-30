import 'package:dio/dio.dart';

import '../base/application_exception.dart';

class ServerException extends ApplicationException {
  final Response? response;

  ServerException(this.response) : super(null);
}
