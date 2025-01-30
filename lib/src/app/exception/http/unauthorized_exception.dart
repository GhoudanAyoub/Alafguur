import 'package:dio/dio.dart';

import 'server_exception.dart';

class UnauthorizedException extends ServerException {
  UnauthorizedException(Response response) : super(response);
}
