import 'package:dio/dio.dart';

import 'server_exception.dart';

class NotFoundException extends ServerException {
  NotFoundException(Response response) : super(response);
}
