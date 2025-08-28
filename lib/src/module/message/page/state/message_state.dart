import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../../../app/exception/http/server_exception.dart';
import '../../../../app/service/auth_service.dart';
import '../../../../app/service/random_service.dart';
import '../../../base/exception/file_uploader/file_uploader_exception.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/file_uploader_service.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/photo_viewer_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../../base/service/user_service.dart';
import '../../../base/utility/image_utility.dart';
import '../../../dashboard/page/state/dashboard_conversation_state.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../../dashboard/service/model/dashboard_conversation_model.dart';
import '../../../profile/service/profile_service.dart';
import '../../service/message_service.dart';
import '../../service/model/message_attachment_model.dart';
import '../../service/model/message_model.dart';

part 'message_state.g.dart';

typedef OnNewMessagesCallback = Function();
typedef OnContentScrollCallback = Function(bool useDelay);

class MessageState = _MessageState with _$MessageState;

abstract class _MessageState with Store {
  final RootState rootState;
  final DashboardUserState dashboardUserState;
  final DashboardConversationState dashboardConversationState;
  final ProfileService profileService;
  final UserService userService;
  final MessageService messageService;
  final AuthService authService;
  final RandomService randomService;
  final FileUploaderService fileUploaderService;
  final ImageUtility imageUtility;

  @observable
  bool isPageLoaded = false;

  @observable
  bool isHistoryLoading = false;

  @observable
  UserModel? profile;

  @observable
  Map<dynamic, MessageModel> messages = {};

  @observable
  List<MessageModel> sortedMessages = [];

  @observable
  UserPermissionModel? permissionReplyMessage;

  @observable
  UserPermissionModel? permissionSendNewMessage;

  @observable
  UserPermissionModel? permissionReadMessage;

  @observable
  bool isMessageValid = false;

  @observable
  bool isContentScrollerActive = false;

  bool isInitialMessagesUpdating = true;
  bool isPrevPageProfile = false;

  final int scrollMessagesThreshold = 5;
  int? lastUnreadMessageId = 0;
  List<int?> unreadMessages = [];
  bool isHistoryLoadAllowed = true;

  int? _opponentId;
  String? _conversationId;
  bool _isMarkingConversationAllowed = true;
  bool _isLoadHistoryReachedEnd = false;

  late ReactionDisposer _userUpdatesWatcherCancellation;
  late ReactionDisposer _userIsLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;
  late ReactionDisposer _messagesUpdatesWatcherCancellation;
  late ReactionDisposer _serverUpdatesWatcherCancellation;

  final String _replyMessagePermissionName = 'mailbox_reply_to_chat_message';
  final String _sendNewMessagePermissionName = 'mailbox_send_chat_message';
  final String _readMessagePermissionName = 'mailbox_read_chat_message';

  final String _serverUpdatesMessagesChannel = 'messages';

  OnNewMessagesCallback? _newMessagesCallback;
  OnContentScrollCallback? _contentScrollCallback;

  _MessageState({
    required this.rootState,
    required this.dashboardUserState,
    required this.dashboardConversationState,
    required this.profileService,
    required this.userService,
    required this.messageService,
    required this.authService,
    required this.randomService,
    required this.fileUploaderService,
    required this.imageUtility,
  });

  @action
  void init(int opponentId) {
    // initialize the conversation id
    _opponentId = opponentId;
    _conversationId = '${authService.authUser!.id}_$opponentId';

    // initial permissions initialization
    if (dashboardUserState.isUserLoaded) {
      _initPermissions();
    }

    _loadInitialResources();

    // init watchers
    _initUserUpdatesWatcher();
    _initIsUserLoadedWatcher();
    _initLastChangedProfileWatcher();
    _initMessagesUpdatesWatcher();
    _initServerUpdatesWatcher();
  }

  void dispose() {
    _userUpdatesWatcherCancellation();
    _userIsLoadedUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
    _messagesUpdatesWatcherCancellation();
    _serverUpdatesWatcherCancellation();
  }

  MessageModel? getPrevMessage(int index) {
    if (sortedMessages.asMap().containsKey(index - 1)) {
      return sortedMessages[index - 1];
    }

    return null;
  }

  /// get form elements for the chat
  List<FormElementModel> getFormElements() {
    return messageService.getFormElements();
  }

  void contentScroll({bool useDelay = true}) {
    if (_contentScrollCallback != null) {
      _contentScrollCallback!(useDelay);
    }
  }

  @action
  void deleteMessage(dynamic id) {
    final Map<dynamic, MessageModel> updatedMessageList = {
      ...messages,
    };

    updatedMessageList.remove(id);

    messages = updatedMessageList;
  }

  @action
  Future<void> resendMessage(MessageModel message) async {
    final messageAttachment =
        message.attachments.isNotEmpty ? message.attachments.first : null;
    final clonedMessage = _cloneMessage(message);

    // clear the error message
    clonedMessage.error = null;

    if (messageAttachment != null) {
      clonedMessage.attachments = [messageAttachment];
    }

    _refreshMessageList([clonedMessage]);

    try {
      // replace a faked message with a real one
      final response = await (messageAttachment != null
          ? messageService.sendImageMessage(
              clonedMessage,
              _opponentId,
              messageAttachment.localFile!,
              _maxAttachmentFileSize,
            )
          : messageService.sendMessage(
              clonedMessage,
              _opponentId,
            ));

      _refreshMessageList([response], skipMessageId: clonedMessage.id);
      // the api returned an error
    } on ServerException catch (error) {
      _processFailedMessage(
        clonedMessage,
        _getResponseError(error),
      );
      // an error while uploading
    } on FileUploaderException catch (error) {
      _processFailedMessage(
        clonedMessage,
        fileUploaderService.getFailedUploadingErrorMessage(
          error,
          _maxAttachmentFileSize,
        ),
      );
    }
  }

  @action
  Future<void> sendImageMessage(PickedFile image) async {
    final imageBytes = await image.readAsBytes();
    final mimeType = imageUtility.getMimeType(image.path, imageBytes);

    // create a new attachment
    final attachment = MessageAttachmentModel(
      downloadUrl: randomService.string(),
      fileName: 'image.${imageUtility.getImageExtension(mimeType!)}',
      type: AttachmentTypeEnum.image,
      bytes: imageBytes,
      localFile: image,
    );

    final newMessage = _getNewMessage(attachment: attachment);

    lastUnreadMessageId = 0;
    _refreshMessageList([newMessage]);
    contentScroll();

    try {
      // replace a faked message with a real one
      final response = await messageService.sendImageMessage(
        newMessage,
        _opponentId,
        image,
        _maxAttachmentFileSize,
      );

      _refreshMessageList([response], skipMessageId: newMessage.id);
      contentScroll();
      // the api returned an error
    } on ServerException catch (error) {
      _processFailedMessage(
        newMessage,
        _getResponseError(error),
      );
      // an error while uploading
    } on FileUploaderException catch (error) {
      _processFailedMessage(
        newMessage,
        fileUploaderService.getFailedUploadingErrorMessage(
          error,
          _maxAttachmentFileSize,
        ),
      );
    }
  }

  @action
  Future<void> sendMessage(String? message) async {
    final newMessage = _getNewMessage(message: message);

    lastUnreadMessageId = 0;
    _refreshMessageList([newMessage]);
    contentScroll();

    try {
      // replace a faked message with a real one
      final response = await messageService.sendMessage(
        newMessage,
        _opponentId,
      );

      _refreshMessageList([response], skipMessageId: newMessage.id);
    } on ServerException catch (error) {
      _processFailedMessage(
        newMessage,
        _getResponseError(error),
      );
    }
  }

  void markMessagesAsRead() {
    if (unreadMessages.isNotEmpty) {
      messageService.markMessagesAsRead(unreadMessages);
      unreadMessages = [];
    }
  }

  Future<PickedFile?> chooseImage(bool useCamera) async {
    try {
      final image = await fileUploaderService.showPhotoUploaderDialog(
        useCamera: useCamera,
      );

      if (image != null &&
          imageUtility.isValidImage(
            imageUtility.getMimeType(image.path, await image.readAsBytes()),
          )) {
        return image;
      }
    } catch (error) {
      rootState.log(
          '[message_state+choose_image] error choosing a photo: ${error.toString()}');
    }
    return null;
  }

  /// get all messages photos
  Map getPhotos(String currentUrl) {
    final List<PhotoViewerModel> photos = [];
    int index = 0;
    int currentPhotoIndex = 0;

    sortedMessages.forEach((message) {
      if (message.attachments.isNotEmpty) {
        message.attachments.forEach((message) {
          if (message.type == AttachmentTypeEnum.image) {
            photos.add(PhotoViewerModel(
              url: message.bytes == null ? message.downloadUrl : null,
              bytes: message.bytes ?? null,
            ));

            if (message.downloadUrl == currentUrl) {
              currentPhotoIndex = index;
            }

            index++;
          }
        });
      }
    });

    return {
      'photos': photos,
      'index': currentPhotoIndex,
    };
  }

  int lastDeliveredMessageIndex() {
    if (sortedMessages.isNotEmpty) {
      int lastDeliveredMessageIndex = 0;

      sortedMessages.asMap().forEach((messageIndex, message) {
        if (message.error == null) {
          lastDeliveredMessageIndex = messageIndex;
        }
      });

      return lastDeliveredMessageIndex;
    }

    return 0;
  }

  bool get isNewConversation => sortedMessages.isEmpty;

  bool isMessageReadingAllowed(MessageModel message) {
    return (message.isAuthorized || permissionReadMessage!.isAllowed) &&
        !message.isLoading;
  }

  bool isMessageReadingAllowedByCredits(MessageModel message) {
    return !message.isAuthorized &&
        !permissionReadMessage!.isAllowed &&
        permissionReadMessage!.isAllowedAfterTracking;
  }

  bool isMessageReadingPromoted(MessageModel message) {
    return !message.isAuthorized &&
        !permissionReadMessage!.isAllowed &&
        permissionReadMessage!.isPromoted &&
        !permissionReadMessage!.isAllowedAfterTracking;
  }

  bool isMessageReadingDenied(MessageModel message) {
    return !message.isAuthorized &&
        !permissionReadMessage!.isAllowed &&
        !permissionReadMessage!.isPromoted &&
        !permissionReadMessage!.isAllowedAfterTracking;
  }

  bool isPlainMessage(MessageModel message) {
    return message.isSystem && message.text == null || !message.isSystem;
  }

  bool isWinkMessage(MessageModel message) {
    final isWink = messageService.isSystemMessageParamsEquals(
      message,
      'wink',
      'renderWink',
    );
    final isWinkBack = messageService.isSystemMessageParamsEquals(
      message,
      'wink',
      'renderWinkBack',
    );
    return message.isSystem && (isWink || isWinkBack);
  }

  /// parse and extract a message from the oembed response
  String getOembedMessage(MessageModel message) {
    try {
      final Map<String, dynamic> params = jsonDecode(message.text!);

      return params['params']['message'] ?? '';
    } catch (error) {
      return '';
    }
  }

  bool isSendMessageAreaAllowed() {
    if (isNewConversation) {
      return permissionSendNewMessage!.isAllowed;
    }

    // continue the conversation
    return permissionReplyMessage!.isAllowed;
  }

  bool isSendMessageAreaPromoted() {
    if (isNewConversation) {
      return permissionSendNewMessage!.isPromoted;
    }

    // continue the conversation
    return permissionReplyMessage!.isPromoted;
  }

  void setNewMessagesCallback(OnNewMessagesCallback newMessagesCallback) {
    _newMessagesCallback = newMessagesCallback;
  }

  void setContentScrollCallback(OnContentScrollCallback forceScrollCallback) {
    _contentScrollCallback = forceScrollCallback;
  }

  /// watch user is loaded updates
  void _initIsUserLoadedWatcher() {
    _userIsLoadedUpdatesWatcherCancellation = reaction(
      (_) => dashboardUserState.isUserLoaded,
      (dynamic _) {
        // make sure we have loaded the opponent's profile
        if (profile != null) {
          isPageLoaded = true;
        }
      },
    );
  }

  /// watch user updates
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.user, (dynamic _) {
      // refresh the permission list
      _initPermissions();

      // make sure we have all messages authorized for viewing
      if (permissionReadMessage!.isAllowed && sortedMessages.isNotEmpty) {
        final notAuthorizedMessage = sortedMessages.firstWhereOrNull(
          (messge) => messge.isAuthorized == false,
        );

        // reload the message list
        if (notAuthorizedMessage != null) {
          _reloadMessages();
        }
      }
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      // synchronize the latest profile's changes
      if (profile != null &&
          dashboardUserState.lastChangedProfile!.id == profile!.id) {
        profile = dashboardUserState.mergeLastChangedProfile(profile!);
      }
    });
  }

  void _initMessagesUpdatesWatcher() {
    _messagesUpdatesWatcherCancellation =
        reaction((_) => messages, (dynamic _) {
      // sort messages
      List messageList =
          messages.entries.map((message) => message.value).toList();
      messageList.sort((a, b) {
        // pending messages should be placed in the end of the list
        int pendingDifference = (a.isPending ? 1 : 0) - (b.isPending ? 1 : 0);

        return pendingDifference != 0
            ? pendingDifference
            : a.timeStamp.compareTo(b.timeStamp);
      });

      // find all unread messages
      unreadMessages = [];
      messageList.forEach((message) {
        if (!message.isRecipientRead && !message.isAuthor) {
          unreadMessages.add(message.id);
        }
      });

      // find a first unread message's id
      if (unreadMessages.isNotEmpty &&
          (isContentScrollerActive || isInitialMessagesUpdating)) {
        lastUnreadMessageId = unreadMessages.first;
      }

      // refresh the messages list
      sortedMessages = List<MessageModel>.from(messageList);
      isInitialMessagesUpdating = false;

      // notify listeners about new messages
      if (unreadMessages.isNotEmpty && _newMessagesCallback != null) {
        _newMessagesCallback!();
      }
    });
  }

  /// watch server updates
  void _initServerUpdatesWatcher() {
    _serverUpdatesWatcherCancellation =
        reaction((_) => rootState.serverUpdates, (dynamic _) {
      final List? newMessages =
          rootState.getServerUpdates(_serverUpdatesMessagesChannel);

      // process new messages
      if (newMessages != null) {
        final List<MessageModel> updatedMessages = [];

        newMessages.forEach((message) {
          final newMessage = MessageModel.fromJson(message);

          // we accept only messages which belong to the current conversation
          if (newMessage.conversation == _conversationId) {
            // skip all pending messages (we don't process them)
            if (newMessage.tempId != null &&
                messages.containsKey(newMessage.tempId)) {
              return;
            }

            // make sure we've recivied either a new or an updated message
            if (!messages.containsKey(newMessage.id) ||
                messages[newMessage.id]!.updateStamp !=
                    newMessage.updateStamp) {
              updatedMessages.add(newMessage);
            }
          }
        });

        // merge changes
        if (updatedMessages.isNotEmpty) {
          _refreshMessageList(updatedMessages);
        }
      }
    });
  }

  @action
  void blockProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.isBlocked = true;
    userService.blockUser(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void unblockProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.isBlocked = false;
    userService.unblockUser(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  Future<void> deleteConversation() {
    return dashboardConversationState.deleteConversation(getConversation()!);
  }

  Future<void> markUserAsViewed() {
    return dashboardConversationState.markMatchedUserAsViewed(
      _opponentId,
    );
  }

  Future<void>? markConversationAsRead() {
    final conversation = getConversation();

    // mark a current conversation as read
    if (_isMarkingConversationAllowed &&
        conversation != null &&
        conversation.isNew) {
      return dashboardConversationState.markConversationAsRead(
        conversation,
      );
    }

    return null;
  }

  Future<void> markConversationAsNew() {
    _isMarkingConversationAllowed = false;
    return dashboardConversationState.markConversationAsNew(
      getConversation()!,
    );
  }

  @action
  Future<void> loadHistory() async {
    if (isHistoryLoading || !_isLoadingHistoryAllowed) {
      return null;
    }

    isHistoryLoading = true;

    final historyMessages = await messageService.loadHistory(
      _opponentId,
      sortedMessages.first.id,
      _messagesLimit,
    );

    // seems we've reached the end
    if (historyMessages.isEmpty || historyMessages.length < _messagesLimit) {
      _isLoadHistoryReachedEnd = true;
    }

    _refreshMessageList(historyMessages);

    isHistoryLoading = false;
  }

  @action
  Future<void> loadMessage(MessageModel message) async {
    final clonedMessage = _cloneMessage(message);
    clonedMessage.isLoading = true;
    _refreshMessageList([clonedMessage]);

    final loadedMessage = await messageService.loadMessage(clonedMessage.id);
    _refreshMessageList([loadedMessage]);
  }

  DashboardConversationModel? getConversation() {
    return dashboardConversationState.getUserConversation(
      profile!.id,
    );
  }

  @action
  Future<void> _loadInitialResources() async {
    final List<Future<dynamic>> loadingResources = [];

    // load last messages
    loadingResources.add(
      messageService.loadMessages(
        _opponentId,
        _messagesLimit,
      ),
    );

    // load the opponent's profile
    loadingResources.add(profileService.loadProfile(_opponentId));

    final List response = await Future.wait(loadingResources);

    // initialize messages and the opponent's profile
    _refreshMessageList(response[0]);
    profile = response[1];

    // make sure conversations were loaded
    if (dashboardUserState.isUserLoaded) {
      isPageLoaded = true;
    }
  }

  @action
  Future<void> _reloadMessages() async {
    isPageLoaded = false;

    final reloadedMessages = await messageService.loadMessages(
      _opponentId,
      sortedMessages.length,
    );

    _refreshMessageList(reloadedMessages);

    isPageLoaded = true;
  }

  UserModel _cloneProfile() {
    return UserModel.fromJson(profile!.toJson());
  }

  MessageModel _cloneMessage(MessageModel message) {
    return MessageModel.fromJson(message.toJson());
  }

  int get _messagesLimit => rootState.getSiteSetting('messagesLimit', 0);

  bool get _isLoadingHistoryAllowed =>
      !_isLoadHistoryReachedEnd && sortedMessages.length >= _messagesLimit;

  void _initPermissions() {
    permissionReplyMessage =
        dashboardUserState.getUserPermission(_replyMessagePermissionName);

    permissionSendNewMessage =
        dashboardUserState.getUserPermission(_sendNewMessagePermissionName);

    permissionReadMessage =
        dashboardUserState.getUserPermission(_readMessagePermissionName);
  }

  @action
  void _refreshMessageList(
    List<MessageModel> updatedMessages, {
    dynamic skipMessageId,
  }) {
    final Map<dynamic, MessageModel> updatedMessageList = {
      ...messages,
      ...Map.fromIterable(updatedMessages, key: (message) => message.id),
    };

    if (skipMessageId != null) {
      updatedMessageList.remove(skipMessageId);
    }

    messages = updatedMessageList;
  }

  @action
  void _processFailedMessage(
    MessageModel message,
    String? errorMessage,
  ) {
    final messageAttachment =
        message.attachments.isNotEmpty ? message.attachments.first : null;
    final updatedMessage = _cloneMessage(message);

    // clear the error message
    updatedMessage.error = errorMessage;

    if (messageAttachment != null) {
      updatedMessage.attachments = [messageAttachment];
    }

    _refreshMessageList([updatedMessage]);
  }

  /// get a new message model
  MessageModel _getNewMessage({
    String? message,
    MessageAttachmentModel? attachment,
  }) {
    final String id = randomService.string();
    final int time = DateTime.now().millisecondsSinceEpoch;

    final newMessage = MessageModel(
      id: id,
      isAuthor: true,
      isSystem: false,
      attachments: attachment != null ? [attachment] : [],
      conversation: _conversationId!,
      isAuthorized: true,
      isPending: true,
      timeStamp: time,
      updateStamp: time,
      tempId: id,
      text: message,
    );

    return newMessage;
  }

  String? _getResponseError(ServerException error) {
    try {
      if (error.response != null) {
        final Map<String, dynamic> params = jsonDecode(
          error.response.toString(),
        );

        if (params['messagesError'] != null) {
          return params['messagesError'];
        }
      }
    } catch (parseError) {}

    // if we don't have an error's explanation throw the error again
    throw error;
  }

  double get _maxAttachmentFileSize {
    final uploadSize = rootState.getSiteSetting('attachMaxUploadSize', 0);

    return uploadSize.toDouble();
  }
}
