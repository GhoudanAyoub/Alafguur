import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';

import '../../../app/service/http_service.dart';
import '../exception/file_uploader/file_not_found_exception.dart';
import '../exception/file_uploader/file_too_large_exception.dart';
import '../exception/file_uploader/file_uploader_exception.dart';
import 'localization_service.dart';

class FileUploaderService {
  final HttpService httpService;
  final LocalizationService localizationService;

  FileUploaderService({
    required this.httpService,
    required this.localizationService,
  });

  /// Displays platform-specific file uploader dialog and resolves into a list
  /// of [PlatformFile] objects representing the selected files.
  ///
  Future<List<PlatformFile>> showFileUploaderDialog({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      // always convert get the file data if running as PWA
      withData: kIsWeb,
    );

    if (pickerResult == null) {
      return [];
    }

    return pickerResult.files;
  }

  Future<PickedFile?> showPhotoUploaderDialog({
    bool useCamera = true,
  }) async {
    final _picker = ImagePicker();

    XFile? file = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);
    return PickedFile(file!.path);
  }

  Future<Uint8List?> getFileBytes(PlatformFile file) async {
    Uint8List? bytes = file.bytes ?? null;

    // read the local file
    if (bytes == null && file.path != null) {
      final fileObject = File(file.path!);
      return await fileObject.readAsBytes();
    }

    return bytes;
  }

  String convertBytesToMb(
    double bytes, {
    int fractionDigits = 2,
  }) {
    return (bytes / 1024 / 1024).toStringAsFixed(fractionDigits);
  }

  /// Upload the given [file] to the provided [uri]. The method is
  /// platform-aware and uses the suitable upload method for each platform.
  ///
  /// If the application is running as PWA, the [file] should contain the
  /// binary data of the target file in its `bytes` field. If the [PlatformFile]
  /// object was obtained by calling the [showFileUploaderDialog] method, it
  /// will contain it.
  ///
  /// Use the [contentType] parameter to set the file's MIME type. Defaults to
  /// `application/octet-stream`.
  ///
  /// The [maxUploadSize] parameter in bytes constrains the maximum upload size of the
  /// file. If the given file is larger, a [FileIsTooLargeException] will be
  /// thrown.
  ///
  Future<dynamic> upload(
    String uri,
    PlatformFile? file, {
    String? contentType,
    double maxUploadSize = -1,
    Map<String, dynamic>? data,
  }) {
    if (kIsWeb) {
      assert(file!.bytes != null);

      return uploadBytes(
        uri,
        file!.bytes!,
        file.name,
        contentType: contentType,
        maxUploadSize: maxUploadSize,
        data: data,
      );
    }

    return uploadFile(
      uri,
      file!.path!,
      filename: file.name,
      contentType: contentType,
      maxUploadSize: maxUploadSize,
      data: data,
    );
  }

  /// get failed uploading error message
  String? getFailedUploadingErrorMessage(
    FileUploaderException error,
    double maxUploadSize,
  ) {
    final exceptionType = error.runtimeType;
    String? errorMessage;

    switch (exceptionType) {
      case FileIsTooLargeException:
        errorMessage = localizationService
            .t('error_file_exceeds_max_upload_size', searchParams: [
          'fileSize',
          'allowedSize',
        ], replaceParams: [
          convertBytesToMb(error.fileSize),
          convertBytesToMb(maxUploadSize),
        ]);
        break;

      default:
        errorMessage = localizationService.t('error_uploading_file');
        break;
    }

    return errorMessage;
  }

  /// Clear temporary files created by the file uploader.
  ///
  /// The platform generally handles temporary files on its own but clearing
  /// them manually might be a good idea if the application handles a lot of
  /// files.
  Future<bool?> clearTemporaryFiles() {
    return FilePicker.platform.clearTemporaryFiles();
  }

  /// Upload bytes to a server by sending a multipart POST request to the given
  /// [uri].
  ///
  /// See the [upload] function documentation for more information.
  Future<dynamic> uploadBytes(
    String uri,
    Uint8List bytes,
    String? filename, {
    String? contentType,
    double maxUploadSize = -1,
    Map<String, dynamic>? data,
  }) {
    if (maxUploadSize > 0 && (bytes.lengthInBytes > maxUploadSize)) {
      throw FileIsTooLargeException(
        sprintf(
            'The given file size of %s bytes is larger than allowed %s bytes',
            [bytes.lengthInBytes, maxUploadSize]),
        bytes.lengthInBytes.toDouble(),
      );
    }

    final file = MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: contentType == null
          ? MediaType('application', 'octet-stream')
          : MediaType.parse(contentType),
    );

    return httpService.post(
      uri,
      files: [
        file,
      ],
      data: data,
    );
  }

  /// Upload file to a server by sending a multipart POST request to the given
  /// [uri].
  ///
  /// See the [upload] function documentation for more information.
  Future<dynamic> uploadFile(
    String uri,
    String path, {
    String? filename,
    String? contentType,
    double maxUploadSize = -1,
    Map<String, dynamic>? data,
  }) async {
    final file = File(path);

    if (!await file.exists()) {
      throw FileNotFoundException(
        sprintf('File %s does not exist', [path]),
        0,
      );
    }

    final fileLength = await file.length();

    if (maxUploadSize > 0 && (fileLength > maxUploadSize)) {
      throw FileIsTooLargeException(
        sprintf(
          'The given file size of %s bytes is larger than allowed %s bytes',
          [fileLength, maxUploadSize],
        ),
        fileLength.toDouble(),
      );
    }

    final actualFileName = filename == null ? p.basename(path) : filename;
    final fileReadStream = file.openRead();

    final multipartFile = MultipartFile.fromStream(
      () => fileReadStream, // Wrap the stream in a function
      fileLength,
      filename: actualFileName,
      contentType: contentType == null
          ? MediaType('application', 'octet-stream')
          : MediaType.parse(contentType),
    );

    return httpService.post(
      uri,
      files: [
        multipartFile,
      ],
      data: data,
    );
  }
}
