import 'file_uploader_exception.dart';

class FileIsTooLargeException extends FileUploaderException {
  FileIsTooLargeException(String? message, double fileSize)
      : super(message, fileSize);
}
