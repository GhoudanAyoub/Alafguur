import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/image_loader_widget.dart';
import '../../service/model/profile_photo_unit_model.dart';

final profilePhotoWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(child: child)
        .backgroundColor(AppSettingsService.themeCommonScaffoldDefaultColor);

final profilePhotoWidgetBackContainer = (
  BuildContext context,
  Function clickCallback,
) =>
    Positioned.directional(
      top: 28,
      end: MediaQuery.of(context).size.width * 0.04,
      textDirection: isRtlMode(context) ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        width: 45,
        height: 45,
        child: Icon(
          CupertinoIcons.chevron_left,
          size: 24,
          color: AppSettingsService.themeCommonIconLightColor,
        ).gestures(
          onTap: () => clickCallback(),
        ),
      ).decorated(
        shape: BoxShape.circle,
        color: AppSettingsService.themeCommonAccentColor,
      ),
    );

final profilePhotoWidgetVideoChatContainer = (
  BuildContext context,
  Function clickCallback,
) =>
    Positioned.directional(
      top: 28,
      end: MediaQuery.of(context).size.width * 0.04,
      textDirection: isRtlMode(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              AppSettingsService.themeCommonProfileVideoChatIconBackgroundColor,
        ),
        child: Icon(
          SkMobileFont.ic_profile_video_chat,
          color: AppSettingsService.themeCommonIconLightColor,
        ),
      ).gestures(
        onTap: () => clickCallback(),
      ),
    );

final Positioned Function({
  required int count,
  int activeIndex,
}) profilePhotoWidgetPaginationContainer = ({
  required int count,
  int? activeIndex,
}) =>
    Positioned.fill(
      bottom: 15,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Styled.widget(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: activeIndex == index
                    ? AppSettingsService.themeCommonAccentColor
                    : AppSettingsService.themeCommonIconLightColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppSettingsService
                        .themeCommonProfilePhotoPaginationShadowColor
                        .withOpacity(0.5),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ).padding(horizontal: 6),
        ),
      ),
    );

final profilePhotoWidgetEditButtonContainer = (
  BuildContext context,
  String? label,
  Function clickCallback,
) =>
    Positioned.directional(
      top: 28,
      end: MediaQuery.of(context).size.width * 0.04,
      textDirection: isRtlMode(context) ? TextDirection.rtl : TextDirection.ltr,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppSettingsService
              .themeCommonProfilePhotoEditButtonBackgroundColor
              .withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
          minimumSize: Size(150, 58),
          elevation: 0,
        ),
        onPressed: () => clickCallback(),
        child: Text(label!).fontSize(18),
      ),
    );

final profilePhotoWidgetPhotoContainer = (
  ProfilePhotoUnitModel photo,
  bool isProfileOwner,
  BuildContext context,
) =>
    Stack(
      children: [
        // a photo
        Positioned.fill(
          child: ImageLoaderWidget(
            imageUrl: photo.url,
            width: null,
            height: null,
          ),
        ),

        // a photo pending bg
        if (!photo.isActive! && isProfileOwner)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppSettingsService.themeCommonDividerColor.withOpacity(0.6),
          ),

        // a photo pending icon
        if (!photo.isActive! && isProfileOwner)
          Icon(
            SkMobileFont.ic_pending,
            color: AppSettingsService.themeCommonPendingIconColor,
            size: MediaQuery.of(context).size.width * 0.18,
          ).alignment(Alignment.center),
      ],
    );

final profilePhotoWidgetMorePhotosButtonContainer = (
  BuildContext context,
  String? label,
  Function clickCallback,
) =>
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppSettingsService.themeCommonAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
          minimumSize: Size(150, 64),
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.09),
        ),
        onPressed: () => clickCallback(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
                  .fontSize(20)
                  .fontWeight(FontWeight.w400)
                  .textAlignment(TextAlign.center)
                  .padding(horizontal: 4),
            ),
            Icon(
              CupertinoIcons.photo_on_rectangle,
              size: 26,
            ).padding(horizontal: 4),
          ],
        ),
      ).alignment(Alignment.center),
    );
