import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/widget/image_loader_widget.dart';
import '../../service/model/edit_photo_unit_model.dart';

final editPhotoApprovalWrapperContainer = (Widget child) => Styled.widget(
      child: child,
    ).padding(left: 16, right: 16, top: 16);

final Widget Function({Widget child}) editPhotoApprovalImageContainer =
    ({Widget? child}) => Styled.widget(
          child: Icon(
            SkMobileFont.ic_pending,
            color: AppSettingsService.themeCommonEditPhotoApprovalTextColor,
            size: 23,
          ),
        );

final editPhotoApprovalTextContainer = (
  String message,
) =>
    Text(
      message,
    )
        .textColor(AppSettingsService.themeCommonEditPhotoApprovalTextColor)
        .fontSize(15)
        .padding(horizontal: 8);

final Widget Function({Widget child}) editPhotoGridContainer =
    ({Widget? child}) => Styled.widget(child: child).padding(all: 16);

final editPhotoPreviewPendingImageContainer = (
  EditPhotoUnitModel photoUnit,
) =>
    Styled.widget(
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (photoUnit.type == EditPhotoUnitType.avatar)
              Image.asset('assets/image/edit/ic_avatar_mask.png'),
            Opacity(
              opacity: 0.6,
              child: photoUnit.url != null
                  ? ImageLoaderWidget(
                      imageUrl: photoUnit.url,
                      width: null,
                      height: null,
                    )
                  : Image.memory(
                      photoUnit.bytes!,
                      width: null,
                      height: null,
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.noRepeat,
                    ),
            ),
          ],
        ),
      ),
    );

final editPhotoPreviewImageContainer = (
  EditPhotoUnitModel photoUnit,
) =>
    Styled.widget(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(10),
              child: ImageLoaderWidget(
                imageUrl: photoUnit.url,
                width: null,
                height: null,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // a photo pending bg
          if (!photoUnit.isActive!)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    AppSettingsService.themeCommonDividerColor.withOpacity(0.6),
              ),
            ),

          if (photoUnit.type == EditPhotoUnitType.avatar)
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                child: Image.asset(
                  'assets/image/edit/ic_avatar_mask.png',
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                ),
              ),
            ),

          // a photo pending icon
          if (!photoUnit.isActive!)
            Icon(
              SkMobileFont.ic_pending,
              color: AppSettingsService.themeCommonPendingIconColor,
              size: 38,
            ).alignment(Alignment.center),
        ],
      ),
    );

final editPhotoEmptySlotContainer = (
  bool isAvatarSlot,
) =>
    Styled.widget(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              child: isAvatarSlot
                  ? Image.asset(
                      'assets/image/edit/ic_avatar_mask.png',
                      width: double.maxFinite,
                    )
                  : null,
            ).backgroundColor(
              AppSettingsService.themeCommonEditPhotoSlotBackgroundColor,
            ),
          ),
        ],
      ),
    );

final editPhotoExtraSlotContainer = () => Styled.widget(
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: AppSettingsService.themeCommonEditPhotoSlotBackgroundColor,
          child: Icon(
            Icons.more_horiz,
            size: 36,
            color: AppSettingsService.themeCommonEditPhotoExtraSlotIconColor,
          ),
        ),
      ),
    );
