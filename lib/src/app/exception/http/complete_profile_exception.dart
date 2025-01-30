import 'package:dio/dio.dart';

import 'server_exception.dart';

class CompleteProfileException extends ServerException {
  CompleteProfileException(Response response) : super(response);
}
