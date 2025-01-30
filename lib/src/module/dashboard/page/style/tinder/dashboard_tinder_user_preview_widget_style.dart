import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../../base/service/model/user_model.dart';

final dashboardTinderUserPreviewWrapperWidgetContainer = (Widget child) =>
    child.backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final dashboardTinderUserPreviewToolbarWidgetContainer =
    (Widget child) => child.padding(
          top: 10,
        );

final dashboardTinderUserPreviewWidgetAvatarContainer =
    (UserModel user) => Expanded(
          child: UserAvatarWidget(
            isUseBigAvatar: true,
            avatarWidth: double.infinity,
            avatarHeight: double.infinity,
            avatar: user.avatar,
            usePendingAvatar: true,
          ),
        );

final dashboardTinderUserPreviewWidgetUserNameContainer = (
  UserModel user,
  BuildContext context, {
  String? distance,
  bool isFiltersAllowed = false,
  Function? filtersCallback,
}) =>
    infoItemContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // basic user info
                Row(
                  children: [
                    // a user's name
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        user.userName!,
                      )
                          .textColor(AppSettingsService.themeCommonTextColor)
                          .fontSize(20),
                    ),

                    // a user's age
                    if (user.age != null)
                      Text(
                        ', ' + user.age.toString(),
                      )
                          .textColor(AppSettingsService.themeCommonTextColor)
                          .fontSize(20),

                    // a user's online status
                    if (user.isOnline!)
                      Icon(
                        Icons.fiber_manual_record,
                        color:
                            AppSettingsService.themeCommonUserCardOnlineColor,
                        size: 14,
                      ).padding(
                        top: 3,
                        horizontal: 3,
                      ),
                  ],
                ).padding(
                  bottom: 4,
                ),

                // distance
                if (distance != null)
                  infoItemValueContainer(
                    distance,
                  ),
              ],
            ),
          ),

          // filters
          if (isFiltersAllowed && filtersCallback != null)
            Styled.widget(
              child: Icon(
                Icons.tune,
                size: 14,
                color: AppSettingsService.themeCommonProfileInfoMoreIconColor,
              ).padding(horizontal: 2),
            )
                .padding(
                  all: 8,
                )
                .decorated(
                  color: transparentColor(),
                  border: Border.all(
                    color:
                        AppSettingsService.themeCommonProfileInfoMoreIconColor,
                  ),
                  shape: BoxShape.circle,
                )
                .gestures(
                  onTap: () => filtersCallback(),
                )
                .padding(
                  horizontal: 10,
                ),
        ],
      ),
      context,
    );

final dashboardTinderUserPreviewWidgetUserCompatibilityContainer = (
  UserModel user,
  BuildContext context,
  String? title,
) =>
    infoItemContainer(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          infoItemLabelContainer(title),
          profileCompatibilityBarSectionContainer(
            context,
            user.compatibility.toString(),
            user.compatibility!.toDouble(),
          ),
        ],
      ),
      context,
    );

final dashboardTinderUserPreviewWidgetUserDescContainer = (
  UserModel user,
  BuildContext context,
  String? title,
) =>
    infoItemContainer(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          infoItemLabelContainer(title),
          infoItemValueContainer(user.aboutMe!),
        ],
      ),
      context,
    );
