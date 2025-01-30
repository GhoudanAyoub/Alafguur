import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../../../app/service/http_service.dart';
import '../../base/service/file_uploader_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import '../../base/utility/image_utility.dart';
import 'model/message_model.dart';

class MessageService {
  final HttpService httpService;
  final FileUploaderService fileUploaderService;
  final ImageUtility imageUtility;

  MessageService({
    required this.httpService,
    required this.fileUploaderService,
    required this.imageUtility,
  });

  /// return chat form elements
  List<FormElementModel> getFormElements() {
    return [
      FormElementModel(
        key: 'message',
        type: FormElements.textarea,
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
        displayValidationError: false,
        params: {
          FormElementParams.autocorrect: true,
        },
      ),
    ];
  }

  /// send an image message
  Future<MessageModel> sendImageMessage(
    MessageModel message,
    int? opponentId,
    PickedFile image,
    double maxUploadSize,
  ) async {
    final requestData = {
      ...message.toJson(),
      'opponentId': opponentId,
    };

    final imageBytes = await image.readAsBytes();
    final mimeType = imageUtility.getMimeType(image.path, imageBytes);

    return MessageModel.fromJson(
      await fileUploaderService.uploadBytes(
        'mailbox/photo-messages',
        imageBytes,
        'image.${imageUtility.getImageExtension(mimeType!)}',
        contentType: mimeType,
        data: requestData,
        maxUploadSize: maxUploadSize,
      ),
    );
  }

  Future<void> markMessagesAsRead(List<int?> ids) {
    return this.httpService.put(
      'mailbox/messages',
      data: {
        'ids': ids,
      },
    );
  }

  /// send a message
  Future<MessageModel> sendMessage(
    MessageModel message,
    int? opponentId,
  ) async {
    return MessageModel.fromJson(
      await this.httpService.post(
        'mailbox/messages',
        data: {
          ...message.toJson(),
          'opponentId': opponentId,
        },
      ),
    );
  }

  /// load a specific message
  Future<MessageModel> loadMessage(int? id) async {
    return MessageModel.fromJson(
      await this.httpService.get('mailbox/messages/$id'),
    );
  }

  /// load old messages
  Future<List<MessageModel>> loadHistory(
    int? userId,
    dynamic firstMessageId,
    int? limit,
  ) async {
    final List messages = await this.httpService.get(
      'mailbox/messages/history/user/$userId',
      queryParameters: {
        'beforeMessageId': firstMessageId,
        'limit': limit,
      },
    );

    final List<MessageModel> messageList =
        messages.map((message) => MessageModel.fromJson(message)).toList();

    return messageList;
  }

  /// load latest messages
  Future<List<MessageModel>> loadMessages(
    int? userId,
    int? limit,
  ) async {
    final List messages = await this.httpService.get(
      'mailbox/messages/user/$userId',
      queryParameters: {
        'limit': limit,
      },
    );

    final List<MessageModel> messageList =
        messages.map((message) => MessageModel.fromJson(message)).toList();

    return messageList;
  }

  /// parse and check a message's type
  bool isSystemMessageParamsEquals(
    MessageModel message,
    String entityType,
    String eventName,
  ) {
    try {
      if (message.text != null) {
        final Map<String, dynamic> params = jsonDecode(message.text!);

        if (params['entityType'] == entityType &&
            params['eventName'] == eventName) {
          return true;
        }
      }
    } catch (error) {}

    return false;
  }
}
