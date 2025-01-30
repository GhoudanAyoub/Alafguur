import 'package:dio/dio.dart';

import 'server_exception.dart';

class SuspendedException extends ServerException {
  SuspendedException(Response response) : super(response);
}
