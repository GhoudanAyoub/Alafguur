import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flag_content_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/page/widget/preview_photo_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../../base/service/model/photo_viewer_model.dart';
import '../../../edit/edit_config.dart';
import '../../../payment/page/widget/payment_access_denied_widget.dart';
import '../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../service/model/profile_photo_unit_model.dart';
import '../state/profile_state.dart';
import '../style/profile_photo_widget_style.dart';
import 'profile_action_widget_mixin.dart';
import 'profile_photo_more_widget.dart';

class ProfilePhotoWidget extends StatelessWidget
    with
        PreviewPhotoWidgetMixin,
        ActionSheetWidgetMixin,
        ModalWidgetMixin,
        FlagContentWidgetMixin,
        FlushbarWidgetMixin,
        ProfileActionWidgetMixin,
        NavigationWidgetMixin,
        PaymentPermissionWidgetMixin {
  final ProfileState state;

  const ProfilePhotoWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final List<Widget> photoWidgets = [
          // photos
          ..._getPhotos(context),

          // an access denied widget
          if (!state.isViewPhotoAllowed)
            PaymentAccessDeniedWidget(
              showUpgradeButton: state.permissionViewPhoto?.isPromoted == true,
            ),

          // view more photos
          if (state.isViewMorePhotosAllowed)
            ProfilePhotoMoreWidget(state: state),
        ];

        return profilePhotoWidgetWrapperContainer(
          Stack(
            children: [
              //photos and extra widgets like permissions and view more
              PageView(
                allowImplicitScrolling: true,
                onPageChanged: (int index) {
                  state.trackPhotoView(index);
                  state.currentPhotoIndex = index;
                },
                children: photoWidgets,
              ),
              // a back button
              profilePhotoWidgetBackContainer(
                context,
                () => _back(context),
              ),
              // a profile edit button
              if (state.isProfileOwner)
                profilePhotoWidgetEditButtonContainer(
                  context,
                  LocalizationService.of(context).t('edit_profile'),
                  () => _pushEditPage(context),
                ),
              // a video chat button
              if (state.isVideoImCallAllowed)
                profilePhotoWidgetVideoChatContainer(
                  context,
                  () => _callUser(context),
                ),
              // a pagination
              profilePhotoWidgetPaginationContainer(
                activeIndex: state.currentPhotoIndex,
                count: photoWidgets.length,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPhotos(BuildContext context) {
    final List<Widget> photos = [];

    state.getPhotos().asMap().forEach(
          (index, photoUnit) => photos.add(
            profilePhotoWidgetPhotoContainer(
              photoUnit,
              state.isProfileOwner,
              context,
            ).gestures(
              onTap: () => _tap(context, index),
              onLongPress: () => _longPress(context, photoUnit),
            ),
          ),
        );

    return photos;
  }

  /// preview photos
  void _tap(BuildContext context, int index) {
    final List<PhotoViewerModel> previewPhotos = state
        .getPhotos()
        .map(
          (photoUnit) => PhotoViewerModel(
            url: photoUnit.url,
          ),
        )
        .toList();

    state.trackPhotoView(index);

    showPhotoList(
      context,
      previewPhotos,
      startIndex: index,
      onFlagCallback:
          !state.isProfileOwner ? onFlagPhotoCallback(context, state) : null,
      onChangeCallback: onChangePhotoCallback(context, state),
    );
  }

  /// show either profile or photo actions
  void _longPress(
    BuildContext context,
    ProfilePhotoUnitModel photoUnit,
  ) {
    if (!state.isProfileOwner) {
      // profile actions
      if (photoUnit.type == ProfilePhotoUnitType.avatar) {
        showProfileActions(context, state);
        return;
      }

      // photo actions
      showPhotoActions(context, photoUnit.id!);
    }
  }

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  void _pushEditPage(BuildContext context) {
    Navigator.pushNamed(context, EDIT_MAIN_URL);
  }

  void _callUser(BuildContext context) {
    if (state.permissionVideoImCall!.isPromoted) {
      showAccessDeniedAlert(context);
      return;
    }

    // The user must be able to call even if they don't have enough credits
    // when only interlocutor is tracked.
    if (state.permissionVideoImTimedCall!.isPromoted &&
        state.isVideoImCallTracked) {
      showAccessDeniedAlert(context);
      return;
    }

    if (!state.profile!.videoImCallPermission!.isPermitted) {
      showMessage(
        state.profile!.videoImCallPermission!.errorMessage!,
        context,
      );

      return;
    }

    state.videoImCallUser();
  }
}
