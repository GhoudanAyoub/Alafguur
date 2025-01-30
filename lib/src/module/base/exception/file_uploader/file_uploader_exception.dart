import '../../../../app/exception/base/application_exception.dart';

class FileUploaderException extends ApplicationException {
  final double fileSize;

  FileUploaderException(String? message, this.fileSize) : super(message);
}
