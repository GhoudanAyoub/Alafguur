import 'package:dio/dio.dart';

import 'server_exception.dart';

class CompleteAccountException extends ServerException {
  CompleteAccountException(Response response) : super(response);
}
