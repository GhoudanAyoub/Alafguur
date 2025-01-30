import 'package:dio/dio.dart';

import 'server_exception.dart';

class EmailNotVerifiedException extends ServerException {
  EmailNotVerifiedException(Response response) : super(response);
}
