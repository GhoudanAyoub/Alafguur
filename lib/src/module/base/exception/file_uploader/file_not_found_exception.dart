import 'file_uploader_exception.dart';

class FileNotFoundException extends FileUploaderException {
  FileNotFoundException(String? message, double fileSize)
      : super(message, fileSize);
}
