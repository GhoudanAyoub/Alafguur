import 'package:dio/dio.dart';

import 'server_exception.dart';

class PhoneCodeNotVerifiedException extends ServerException {
  PhoneCodeNotVerifiedException(Response response) : super(response);
}
