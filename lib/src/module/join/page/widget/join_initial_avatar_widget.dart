import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/keyboard_widget_mixin.dart';
import '../../../base/page/widget/loading_spinner_widget.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/photo_uploader_chooser_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../service/model/join_initial_avatar_model.dart';
import '../state/join_initial_avatar_state.dart';
import '../style/join_initial_avatar_widget_style.dart';

typedef AvatarUploadedCallback = void Function(
  JoinInitialAvatarModel? avatarData,
);
typedef AvatarStartUploadingCallback = void Function();
typedef AvatarFinishUploadingCallback = void Function();

final serviceLocator = GetIt.instance;

class JoinInitialAvatarWidget extends StatefulWidget
    with
        FlushbarWidgetMixin,
        ModalWidgetMixin,
        ActionSheetWidgetMixin,
        KeyboardWidgetMixin,
        PhotoUploaderChooserWidgetMixin {
  final AvatarUploadedCallback onAvatarUploadCallback;
  final AvatarStartUploadingCallback onAvatarStartUploadingCallback;
  final AvatarFinishUploadingCallback onAvatarFinishUploadingCallback;

  JoinInitialAvatarWidget({
    Key? key,
    required this.onAvatarUploadCallback,
    required this.onAvatarStartUploadingCallback,
    required this.onAvatarFinishUploadingCallback,
  }) : super(key: key);

  @override
  _JoinInitialAvatarWidgetState createState() =>
      _JoinInitialAvatarWidgetState();
}

class _JoinInitialAvatarWidgetState extends State<JoinInitialAvatarWidget> {
  late final JoinInitialAvatarState _state;

  @override
  void initState() {
    super.initState();
    _state = serviceLocator.get<JoinInitialAvatarState>();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        children: [
          joinInitialAvatarWidgetImageContainer(
            Container(
              child: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // a loading bar
                    if (_state.isUploadInProgress) LoadingSpinnerWidget(),

                    // a loaded preview avatar container
                    if (!_state.isUploadInProgress && _state.avatarData != null)
                      joinInitialAvatarWidgetPreviewImageContainer(
                        _state.avatarData!.url,
                      ),

                    // an empty preview avatar container
                    if (!_state.isUploadInProgress && _state.avatarData == null)
                      joinInitialAvatarWidgetIconContainer(),
                  ],
                ),
                // an uploader button
                if (!_state.isUploadInProgress && _state.avatarData == null)
                  joinInitialAvatarWidgetTextContainer(
                    LocalizationService.of(context).t('choose_avatar'),
                  )
              ].toColumn(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ).gestures(
            onTap: () => _chooseAvatar(),
          ),
          // a delete button
          if (!_state.isUploadInProgress && _state.isImageLoaded)
            joinInitialAvatarWidgetDeleteIconContainer(
              context,
              () => widget.showConfirmation(
                context,
                'delete_avatar_confirmation',
                deleteAvatarCallback(),
              ),
            )
        ],
      ),
    );
  }

  void _chooseAvatar() async {
    // return if avatar is already uploading
    if (_state.isUploadInProgress) {
      return;
    }

    widget.displayPhotoUploadChooser(
      context,
      () => _uploadAvatar(true),
      () => _uploadAvatar(false),
    );
  }

  void _uploadAvatar(bool useCamera) async {
    // wait for the file picker to return
    final avatar = await _state.chooseAvatar(useCamera);

    if (avatar == null) {
      widget.showMessage('error_choose_correct_avatar', context);

      return;
    }

    // enter the upload in progress state immediately after the avatar is
    // selected to prevent multiple uploads
    _state.startUploading();
    widget.onAvatarStartUploadingCallback();

    // uploaded selected avatar
    final errorMessage = await _state.upload(avatar);

    _state.finishUploading();

    if (errorMessage != null) {
      _state.isImageLoaded = false;
      widget.showMessage(errorMessage, context);
      widget.onAvatarFinishUploadingCallback();

      return;
    }

    // an image has been uploaded
    _state.isImageLoaded = true;

    // notify a parent widget about uploaded avatar
    widget.onAvatarUploadCallback(
      JoinInitialAvatarModel.fromJson(
        _state.avatarData!.toJson(),
      ),
    );

    widget.onAvatarFinishUploadingCallback();
  }

  OnConfirmCallback deleteAvatarCallback() {
    return () {
      _state.deleteAvatar();
      widget.onAvatarUploadCallback(null);
    };
  }
}
