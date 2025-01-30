import 'package:flutter/widgets.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flag_content_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/preview_photo_widget_mixin.dart';
import '../../../base/service/model/action_sheet_model.dart';
import '../../service/model/profile_photo_unit_model.dart';
import '../state/profile_state.dart';

mixin ProfileActionWidgetMixin
    on
        ActionSheetWidgetMixin,
        FlagContentWidgetMixin,
        FlushbarWidgetMixin,
        ModalWidgetMixin {
  void showPhotoActions(
    BuildContext context,
    int photoId,
  ) {
    showActionSheet(context, [
      ActionSheetModel(
        label: 'flag_photo',
        callback: () => showFlagContent(
          context,
          photoId,
          'photo_comments',
          onFlaggedCallback: () => _onFlaggedPhotoCallback(context),
        ),
      ),
    ]);
  }

  void showProfileActions(
    BuildContext context,
    ProfileState state,
  ) {
    showActionSheet(context, [
      ActionSheetModel(
        label: 'flag_profile',
        callback: () => showFlagContent(
          context,
          state.profile!.id!,
          'user_join',
          onFlaggedCallback: () => _onFlaggedProfileCallback(context),
        ),
      ),
      if (state.profile!.isBlocked!)
        ActionSheetModel(
          label: 'unblock_profile',
          callback: () => state.unblockProfile(),
        ),
      if (!state.profile!.isBlocked!)
        ActionSheetModel(
          label: 'block_profile',
          callback: () => _blockProfile(context, state),
        ),
    ]);
  }

  /// on flag photo callback
  OnFlagCallback onFlagPhotoCallback(
    BuildContext context,
    ProfileState state, {
    bool isLimited = true,
  }) {
    return (int index) {
      final ProfilePhotoUnitModel photoUnit =
          state.getPhotos(isLimited: isLimited)[index];

      // profile actions
      if (photoUnit.type == ProfilePhotoUnitType.avatar) {
        showProfileActions(context, state);

        return;
      }

      // photo actions
      showPhotoActions(context, photoUnit.id!);
    };
  }

  /// on change photo callback
  OnFlagCallback onChangePhotoCallback(
    BuildContext context,
    ProfileState state, {
    bool isLimited = true,
  }) {
    return (int index) => state.trackPhotoView(
          index,
          isLimited: isLimited,
        );
  }

  void _onFlaggedProfileCallback(BuildContext context) {
    showMessage('profile_reported', context);
  }

  void _onFlaggedPhotoCallback(BuildContext context) {
    showMessage('photo_reported', context);
  }

  void _blockProfile(
    BuildContext context,
    ProfileState state,
  ) {
    showConfirmation(
      context,
      'block_profile_confirmation',
      () => state.blockProfile(),
      noLabel: 'cancel',
      yesLabel: 'block_profile',
    );
  }
}
