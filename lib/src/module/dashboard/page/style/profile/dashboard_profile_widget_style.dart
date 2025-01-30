import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../../base/service/model/user_avatar_model.dart';

final dashboardProfileWidgetWrapperContainer = (
  ScrollController controller,
  List<Widget> children,
) =>
    SingleChildScrollView(
      child: Column(
        children: children,
      ).padding(
        vertical: 16,
      ),
    ).backgroundColor(
      AppSettingsService.themeCustomDashboardProfileWrapperBackgroundColor,
    );
final dashboardProfileWidgetInfoWrapperContainer = (
  BuildContext context,
  Widget child,
  Widget userName,
  Widget userDesc,
  Widget buttons,
) =>
    Stack(
      children: [
        Column(
          children: [
            userName,
            userDesc,
            buttons,
          ],
        ).padding(top: 85).decorated(
          color: AppSettingsService
              .themeCustomDashboardProfileInfoWrapperBackgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppSettingsService
                  .themeCustomDashboardProfileInfoWrapperShadowColor,
              blurRadius: 12,
            ),
          ],
        ).padding(
          top: 69,
        ),
        Positioned(
          child: Container(
            child: child,
          ).width(136).height(136).alignment(
                Alignment.center,
              ),
        ),
      ],
    )
        .constrained(
          maxWidth: MediaQuery.of(context).size.width * 0.91,
        )
        .padding(bottom: 36);

final dashboardProfileWidgetAvatarContainer = (
  BuildContext context,
  UserAvatarModel? avatar,
  Function clickCallback,
) =>
    ClipOval(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // a user avatar
          ClipOval(
            child: UserAvatarWidget(
              usePendingAvatar: true,
              isUseBigAvatar: false,
              avatarWidth: 120,
              avatarHeight: 120,
              avatar: avatar,
            ),
          ).gestures(
            onTap: () => clickCallback(),
          ),

          // an avatar pending bg
          if (avatar?.active == false)
            ClipOval(
              child: Container(
                width: 120,
                height: 120,
                color:
                    AppSettingsService.themeCommonDividerColor.withOpacity(0.6),
              ),
            ).gestures(
              onTap: () => clickCallback(),
            ),

          // an avatar pending icon
          if (avatar?.active == false)
            Icon(
              SkMobileFont.ic_pending,
              color: AppSettingsService.themeCommonPendingIconColor,
              size: 38,
            ),
        ],
      )
          .padding(
            all: 8,
          )
          .backgroundColor(
            AppSettingsService.themeCustomDashboardProfileAvatarBackgroundColor,
          ),
    );

final dashboardProfileWidgetUserNameContainer = (
  String? userName,
) =>
    Text(userName!)
        .fontSize(20)
        .fontWeight(FontWeight.bold)
        .textColor(
          AppSettingsService.themeCommonDashboardProfileUserNameColor,
        )
        .padding(
          horizontal: 16,
          bottom: 4,
        );

final dashboardProfileWidgetUserDescContainer = (
  String? userDesc,
) =>
    userDesc == null
        ? Container()
        : Text(
            userDesc,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 2,
          )
            .fontSize(18)
            .textColor(
              AppSettingsService.themeCommonDashboardProfileUserDescColor,
            )
            .textAlignment(TextAlign.center)
            .padding(
              horizontal: 16,
            );

final dashboardProfileWidgetButtonsWrapperContainer = (
  String? editTitle,
  Function editClickCallback,
  String? settingTitle,
  Function settingsClickCallback,
  BuildContext context,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Icon(
                        SkMobileFont.profile,
                        color: AppSettingsService.themeCommonIconLightColor,
                        size: 18,
                      ),
                      backgroundColor:
                          AppSettingsService.themeCommonAccentColor,
                    ).gestures(
                      onTap: () => editClickCallback(),
                    ),
                    TextButton(
                      child: Text(
                        editTitle!,
                      )
                          .fontSize(
                            14,
                          )
                          .fontWeight(FontWeight.w500)
                          .padding(
                            horizontal: 8,
                          ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppSettingsService
                            .themeCustomDashboardProfileButtonBackgroundColor,
                      ),
                      onPressed: () => editClickCallback(),
                    ),
                  ],
                ).padding(
                  top: 28,
                  bottom: 12,
                ),
              ),
            ],
          ).decorated(
            border: BorderDirectional(
              end: BorderSide(
                color: AppSettingsService
                    .themeCustomDashboardProfileInfoWrapperBorderColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              CircleAvatar(
                child: Icon(
                  SkMobileFont.theme_5_settings,
                  color: AppSettingsService.themeCommonIconLightColor,
                  size: 18,
                ),
                backgroundColor: AppSettingsService.themeCommonAccentColor,
              ).gestures(
                onTap: () => settingsClickCallback(),
              ),
              TextButton(
                child: Text(
                  settingTitle!,
                )
                    .fontSize(
                      14,
                    )
                    .fontWeight(FontWeight.w500)
                    .padding(
                      horizontal: 8,
                    ),
                style: TextButton.styleFrom(
                  foregroundColor: AppSettingsService
                      .themeCustomDashboardProfileButtonBackgroundColor,
                ),
                onPressed: () => settingsClickCallback(),
              )
            ],
          ).padding(
            top: 28,
            bottom: 12,
          ),
        ),
      ],
    )
        .decorated(
          border: BorderDirectional(
            top: BorderSide(
              color: AppSettingsService
                  .themeCustomDashboardProfileInfoWrapperBorderColor,
            ),
          ),
        )
        .padding(
          top: 44,
        );

final dashboardProfileWidgetPageLinksWrapperContainer = (
  List<Widget> children,
) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

final dashboardProfileWidgetPageLinkContainer = (
  String? title,
  Function clickCallback,
) =>
    TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(0, 50),
      ),
      child: Text(
        title!.toUpperCase(),
      )
          .fontSize(14)
          .fontWeight(
            FontWeight.w700,
          )
          .textColor(
            AppSettingsService.themeCommonDashboardProfileLinkColor,
          ),
      onPressed: () => clickCallback(),
    );

final dashboardProfileWidgetGuideLinkContainer = (
  String? title,
  Function clickCallback,
) =>
    TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(0, 50),
        backgroundColor:
            AppSettingsService.themeCommonDashboardProfileGuideBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Text(
        title!.toUpperCase(),
      )
          .fontSize(14)
          .fontWeight(
            FontWeight.w700,
          )
          .textColor(
            AppSettingsService.themeCommonDashboardProfileGuideColor,
          ),
      onPressed: () => clickCallback(),
    );

final dashboardProfileWidgetGuestsLinkContainer = (
  String? title,
  Function clickCallback,
  int newGuests,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // a button
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(0, 48),
          ),
          child: Text(
            title!.toUpperCase(),
          )
              .fontSize(14)
              .fontWeight(
                FontWeight.w700,
              )
              .textColor(
                AppSettingsService.themeCommonDashboardProfileLinkColor,
              ),
          onPressed: () => clickCallback(),
        ),
        // a guest counter
        if (newGuests > 0)
          SizedBox(
            child: Text(
              (newGuests <= 99 ? newGuests.toString() : '99+'),
            )
                .textColor(AppSettingsService.themeCommonHardcodedWhiteColor)
                .fontSize(12)
                .fontWeight(FontWeight.bold)
                .alignment(Alignment.center),
          )
              .constrained(
                minWidth: 16,
                minHeight: 16,
              )
              .padding(all: 2)
              .backgroundColor(
                AppSettingsService.themeCustomNotificationBackgroundColor,
              )
              .clipOval()
              .padding(
                horizontal: 6,
              ),
      ],
    );
