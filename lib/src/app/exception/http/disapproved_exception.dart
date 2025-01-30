import 'package:dio/dio.dart';

import 'server_exception.dart';

class DisapprovedException extends ServerException {
  DisapprovedException(Response response) : super(response);
}
