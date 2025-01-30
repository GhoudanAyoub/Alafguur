import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../../base/service/model/user_avatar_model.dart';
import '../../../animation/dashboard_tinder_loading_widget_radar_animation.dart';

final dashboardTinderLoadingWidgetAvatarContainer = ({
  UserAvatarModel? avatar,
  double avatarWidth = 120,
  double avatarHeight = 120,
}) =>
    Stack(
      alignment: Alignment.center,
      children: [
        // a user avatar
        ClipOval(
          child: UserAvatarWidget(
            isUseBigAvatar: false,
            avatarWidth: avatarWidth,
            avatarHeight: avatarHeight,
            avatar: avatar,
            usePendingAvatar: true,
          ),
        ),

        // an avatar pending bg
        if (avatar != null && avatar.active == false)
          ClipOval(
            child: Container(
              width: avatarWidth,
              height: avatarHeight,
              color:
                  AppSettingsService.themeCommonDividerColor.withOpacity(0.6),
            ),
          ),

        // an avatar pending icon
        if (avatar != null && avatar.active == false)
          Icon(
            SkMobileFont.ic_pending,
            color: AppSettingsService.themeCommonPendingIconColor,
            size: 38,
          )
      ],
    );

final dashboardTinderLoadingWidgetNoUsersContainer = (
  String? header,
  String? desc,
) =>
    Column(
      children: [
        Text(header!)
            .textColor(AppSettingsService.themeCommonBlankTitleColor)
            .fontSize(20)
            .padding(
              bottom: 12,
            ),
        Text(desc!)
            .fontSize(18)
            .textColor(AppSettingsService.themeCommonBlankDescrColor)
            .padding(
              bottom: 20,
            ),
      ],
    );

final dashboardTinderLoadingWidgetFiltersContainer = (
  String? text,
  Function clickCallback,
) =>
    TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppSettingsService.themeCommonAccentColor,
      ),
      child: Text(
        text!,
      ),
      onPressed: () => clickCallback(),
    );

final dashboardTinderLoadingWidgetRadarAnimationAvatarContainer = (
  AnimationController controller,
  UserAvatarModel? avatar,
) =>
    CustomPaint(
      painter: DashboardTinderLoadingWidgetRadarAnimation(
        controller,
        strokeColor: AppSettingsService
            .themeCustomDashboardTinderLoadingWidgetRadarEndColor,
        gradientStops: [
          AppSettingsService
              .themeCustomDashboardTinderLoadingWidgetRadarStartColor,
          AppSettingsService
              .themeCustomDashboardTinderLoadingWidgetRadarEndColor,
        ],
        gradientAngle: 138,
      ),
      child: dashboardTinderLoadingWidgetAvatarContainer(
        avatar: avatar,
      ),
    ).padding(
      bottom: 60,
    );
