import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flag_content_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/preview_photo_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../../base/service/model/photo_viewer_model.dart';
import '../../../edit/edit_config.dart';
import '../state/profile_state.dart';
import '../style/profile_photo_widget_style.dart';
import 'profile_action_widget_mixin.dart';

class ProfilePhotoMoreWidget extends StatelessWidget
    with
        PreviewPhotoWidgetMixin,
        ActionSheetWidgetMixin,
        ModalWidgetMixin,
        FlagContentWidgetMixin,
        FlushbarWidgetMixin,
        ProfileActionWidgetMixin {
  final ProfileState state;

  const ProfilePhotoMoreWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return state.isProfileOwner
        ? _ownerMorePhotos(context)
        : _profileMorePhotos(context);
  }

  Widget _ownerMorePhotos(BuildContext context) {
    return profilePhotoWidgetMorePhotosButtonContainer(
      context,
      LocalizationService.of(context).t('manage_photos'),
      () => _pushEditPhotosPage(context),
    );
  }

  Widget _profileMorePhotos(BuildContext context) {
    return profilePhotoWidgetMorePhotosButtonContainer(
      context,
      LocalizationService.of(context).t('view_all_photos'),
      () => _showAllProfilePhotos(context),
    );
  }

  void _showAllProfilePhotos(BuildContext context) {
    final List<PhotoViewerModel> previewPhotos = state
        .getPhotos(isLimited: false)
        .map(
          (photoUnit) => PhotoViewerModel(
            url: photoUnit.url,
          ),
        )
        .toList();

    showPhotoList(
      context,
      previewPhotos,
      onFlagCallback: onFlagPhotoCallback(context, state, isLimited: false),
      onChangeCallback: onChangePhotoCallback(
        context,
        state,
        isLimited: false,
      ),
    );
  }

  void _pushEditPhotosPage(BuildContext context) {
    Navigator.pushNamed(context, EDIT_PHOTOS_URL);
  }
}
