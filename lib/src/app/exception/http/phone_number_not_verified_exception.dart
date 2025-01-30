import 'package:dio/dio.dart';

import 'server_exception.dart';

class PhoneNumberNotVerifiedException extends ServerException {
  PhoneNumberNotVerifiedException(Response response) : super(response);
}
