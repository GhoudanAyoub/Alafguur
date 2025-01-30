import 'package:dio/dio.dart';

import '../base/application_exception.dart';

class NoInternetException extends ApplicationException {
  final Response? response;

  NoInternetException(this.response) : super(null);
}
