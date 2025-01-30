import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/keyboard_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/page/widget/preview_photo_widget_mixin.dart';
import '../../../base/service/model/action_sheet_model.dart';
import '../../../base/service/model/photo_viewer_model.dart';
import '../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../edit_config.dart';
import '../../service/model/edit_photo_unit_model.dart';
import '../state/edit_photo_state.dart';
import '../style/edit_photo_widget_style.dart';

final serviceLocator = GetIt.instance;

class EditPhotoWidget extends StatefulWidget
    with
        PreviewPhotoWidgetMixin,
        ActionSheetWidgetMixin,
        ModalWidgetMixin,
        NavigationWidgetMixin,
        FlushbarWidgetMixin,
        KeyboardWidgetMixin,
        PaymentPermissionWidgetMixin {
  final bool isPreviewMode;
  final int maxPreviewSlots;
  final int minSlots;
  final int slotsPerRow;

  EditPhotoWidget({
    Key? key,
    this.isPreviewMode = false,
    this.maxPreviewSlots = 9,
    this.minSlots = 15,
    this.slotsPerRow = 3,
  }) : super(key: key);

  @override
  EditPhotoWidgetState createState() => EditPhotoWidgetState();
}

class EditPhotoWidgetState extends State<EditPhotoWidget> {
  late final EditPhotoState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<EditPhotoState>();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => widget.isPreviewMode
          ? _previewPhotoGrid(
              _state.getPhotoList(),
            )
          : _photoGrid(
              _state.getPhotoList(),
              _state.getApprovalMessage(),
            ),
    );
  }

  void showAllActions() {
    widget.showActionSheet(context, [
      ..._getAvatarActions(),
      ..._getPhotoActions(-1),
    ]);
  }

  /// generate a photo grid for the preview mode (with the limited number of photos)
  Widget _previewPhotoGrid(List<PhotoViewerModel> allPhotos) {
    return editPhotoGridContainer(
      child: GridView.builder(
        itemCount: widget.maxPreviewSlots,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.slotsPerRow,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) =>
            _renderSlot(index).gestures(
          onTap: () => _tap(index, allPhotos),
          onLongPress: () => _longPress(index),
        ),
      ),
    );
  }

  /// generate a full photo grid
  Widget _photoGrid(
    List<PhotoViewerModel> allPhotos,
    String? approvalMessage,
  ) {
    return CustomScrollView(
      slivers: <Widget>[
        // an approval message
        if (approvalMessage != null)
          SliverToBoxAdapter(
            child: editPhotoApprovalWrapperContainer(
              Row(
                children: [
                  editPhotoApprovalImageContainer(),
                  Expanded(
                    child: editPhotoApprovalTextContainer(
                      approvalMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // photo list
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.slotsPerRow,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _renderSlot(index).gestures(
                    onTap: () => _tap(index, allPhotos),
                    onLongPress: () => _longPress(index));
              },
              childCount: _state.getMaxSlotsCount(
                widget.minSlots,
                widget.slotsPerRow,
              ),
            ),
          ),
        ),

        // Place sliver widgets here
      ],
    );
  }

  /// render different kind of slots images, actions, empty
  Widget _renderSlot(int index) {
    if (_state.isExtraSlot(
        index, widget.isPreviewMode, widget.maxPreviewSlots)) {
      return _renderExtraActionsSlot(index);
    }

    return _renderImageSlot(
      index,
      _state.getImageByIndex(index),
    );
  }

  /// render an image slot
  Widget _renderImageSlot(int index, EditPhotoUnitModel? photoUnit) {
    if (photoUnit != null) {
      if (photoUnit.isPending!) {
        return editPhotoPreviewPendingImageContainer(photoUnit);
      }

      return editPhotoPreviewImageContainer(photoUnit);
    }

    return _renderEmptySlot(index);
  }

  /// render an empty slot
  Widget _renderEmptySlot(int index) {
    return editPhotoEmptySlotContainer(index == _state.avatarIndex);
  }

  /// render an action slot
  Widget _renderExtraActionsSlot(int index) {
    return editPhotoExtraSlotContainer();
  }

  /// tapping on photos
  void _tap(int index, List<PhotoViewerModel> allPhotos) {
    // make sure we have a photo by the received index
    if (_state.getImageByIndex(index) != null &&
        !_state.isExtraSlot(
          index,
          widget.isPreviewMode,
          widget.maxPreviewSlots,
        )) {
      // preview photos
      widget.showPhotoList(
        context,
        allPhotos,
        startIndex: _state.avatar != null ? index : index - 1,
      );

      return;
    }

    _showActions(index);
  }

  /// long pressing on photos
  void _longPress(int index) {
    final photoUnit = _state.getImageByIndex(index);

    if (photoUnit != null && !photoUnit.isPending!) {
      _showActions(index);
    }
  }

  /// show different kind of actions
  void _showActions(int index) {
    // show avatar actions
    if (_state.isAvatarSlot(index)) {
      widget.showActionSheet(context, _getAvatarActions());

      return;
    }

    // show extra actions
    if (_state.isExtraSlot(
        index, widget.isPreviewMode, widget.maxPreviewSlots)) {
      widget.showActionSheet(context, _getExtraActions());

      return;
    }

    // show photo actions
    final photoActions = _getPhotoActions(index);
    if (photoActions.isNotEmpty) {
      widget.showActionSheet(context, _getPhotoActions(index));
    }
  }

  /// get avatar actions
  List<ActionSheetModel> _getAvatarActions() {
    return [
      ActionSheetModel(
        label: 'take_photo_for_avatar',
        callback: () => _uploadImage(true, true),
      ),
      ActionSheetModel(
        label: 'select_avatar',
        callback: () => _uploadImage(true, false),
      ),
      if (_state.isAvatarDeletingAllowed())
        ActionSheetModel(
          label: 'delete_avatar',
          callback: _deleteAvatar,
        ),
    ];
  }

  /// get photo actions
  List<ActionSheetModel> _getPhotoActions(int index) {
    List<ActionSheetModel> actions = [];

    if (_state.permission?.isAllowed == true ||
        _state.permission?.isPromoted == true) {
      actions.add(
        ActionSheetModel(
          label: 'take_photo',
          callback: _state.permission!.isAllowed
              ? () => _uploadImage(false, true)
              : widget.showAccessDeniedAlert,
        ),
      );
      actions.add(
        ActionSheetModel(
          label: 'select_photo',
          callback: _state.permission!.isAllowed
              ? () => _uploadImage(false, false)
              : widget.showAccessDeniedAlert,
        ),
      );
    }

    final photoUnit = _state.getImageByIndex(index);

    if (photoUnit != null && !photoUnit.isPending!) {
      // make as avatar
      if (_state.avatar != null && !_state.avatar!.isPending! ||
          _state.avatar == null) {
        actions.add(
          ActionSheetModel(
            label: 'set_avatar',
            callback: () => _makePhotoAsAvatar(photoUnit),
          ),
        );
      }

      // delete photo
      actions.add(
        ActionSheetModel(
          label: 'delete_photo',
          callback: () => _deletePhoto(photoUnit),
        ),
      );
    }

    return actions;
  }

  /// get photo extra actions
  List<ActionSheetModel> _getExtraActions() {
    List<ActionSheetModel> actions = [];

    actions.add(
      ActionSheetModel(
        label: 'view_all_photos',
        callback: _pushEditPhotosPage,
      ),
    );

    if (_state.permission?.isAllowed == true ||
        _state.permission?.isPromoted == true) {
      actions.add(
        ActionSheetModel(
          label: 'take_photo',
          callback: _state.permission!.isAllowed
              ? () => _uploadImage(false, true)
              : widget.showAccessDeniedAlert,
        ),
      );
      actions.add(
        ActionSheetModel(
          label: 'select_photo',
          callback: _state.permission!.isAllowed
              ? () => _uploadImage(false, false)
              : widget.showAccessDeniedAlert,
        ),
      );
    }

    return actions;
  }

  /// upload a new user photo or avatar
  Future<void> _uploadImage(
    bool isAvatar,
    bool useCamera,
  ) async {
    widget.hideKeyboard();

    // wait for the file picker to return
    final image = await _state.chooseImage(useCamera);

    if (image != null) {
      final errorMessage = !isAvatar
          ? await _state.uploadPhoto(image)
          : await _state.uploadAvatar(image);

      if (this.mounted) {
        if (errorMessage == null) {
          !isAvatar
              ? widget.showMessage('photo_has_been_uploaded', context)
              : widget.showMessage('avatar_has_been_uploaded', context);

          return;
        }

        widget.showAlert(context, errorMessage, translate: false);
      }

      return;
    }

    if (isAvatar) {
      widget.showMessage('error_choose_correct_avatar', context);

      return;
    }

    widget.showMessage('error_choose_correct_photo', context);
  }

  /// delete the user's avatar
  void _deleteAvatar() {
    widget.showConfirmation(context, 'delete_avatar_confirmation', () {
      _state.deleteAvatar();
      widget.showMessage('avatar_has_been_deleted', context);
    });
  }

  /// delete the user's photo
  void _deletePhoto(EditPhotoUnitModel photoUnit) {
    widget.showConfirmation(
      context,
      'delete_photo_confirmation',
      () {
        _state.deletePhoto(photoUnit);
        widget.showMessage('photo_has_been_deleted', context);
      },
    );
  }

  /// make the user's photo as avatar
  void _makePhotoAsAvatar(EditPhotoUnitModel photoUnit) {
    _state.makePhotoAsAvatar(photoUnit);
    widget.showMessage('photo_set_avatar', context);
  }

  void _pushEditPhotosPage() {
    Navigator.pushNamed(context, EDIT_PHOTOS_URL);
  }
}
