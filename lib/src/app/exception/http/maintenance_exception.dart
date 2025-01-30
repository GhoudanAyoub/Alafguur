import 'package:dio/dio.dart';

import 'server_exception.dart';

class MaintenanceException extends ServerException {
  MaintenanceException(Response response) : super(response);
}
