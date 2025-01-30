import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/widget/user_avatar_widget.dart';
import '../../../base/service/model/user_model.dart';
import '../../service/model/dashboard_matched_user_model.dart';

final dashboardMatchedUserWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(child: child).decorated(
        gradient: LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(0, 0),
            colors: [
          AppSettingsService.themeCommonMatchedUserBackgroundGradientStartColor,
          AppSettingsService.themeCommonMatchedUserBackgroundGradientEndColor,
        ]));

final dashboardMatchedUserWidgetHeaderContainer = (
  String? header,
  String? description,
) =>
    Styled.widget(
      child: Column(
        children: [
          // header text
          Text(
            header!,
            textAlign: TextAlign.center,
          )
              .fontSize(46)
              .fontWeight(FontWeight.w700)
              .textColor(
                AppSettingsService.themeCommonMatchedUserHeaderTextColor,
              )
              .alignment(Alignment.center),
          // description text
          Text(
            description!,
            textAlign: TextAlign.center,
          )
              .fontSize(18)
              .textColor(
                AppSettingsService.themeCommonMatchedUserDescColor,
              )
              .padding(bottom: 38),
        ],
      ),
    ).padding(
      top: 50,
    );

final dashboardMatchedUserWidgetAvatarsContainer = (
  UserModel? me,
  DashboardMatchedUserModel matchedUser, {
  double avatarWidth = 120,
  double avatarHeight = 120,
}) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // me
        Stack(
          alignment: Alignment.center,
          children: [
            // a user avatar
            ClipOval(
              child: UserAvatarWidget(
                isUseBigAvatar: false,
                avatarWidth: avatarWidth,
                avatarHeight: avatarHeight,
                avatar: me!.avatar,
                usePendingAvatar: true,
              ),
            ).padding(horizontal: 15),

            // an avatar pending bg
            if (me.avatar?.active == false)
              ClipOval(
                child: Container(
                  width: avatarWidth,
                  height: avatarHeight,
                  color: AppSettingsService.themeCommonDividerColor
                      .withOpacity(0.6),
                ),
              ),

            // an avatar pending icon
            if (me.avatar?.active == false)
              Icon(
                SkMobileFont.ic_pending,
                color: AppSettingsService.themeCommonPendingIconColor,
                size: 38,
              ).alignment(Alignment.center),
          ],
        ),
        // a matched user
        ClipOval(
          child: UserAvatarWidget(
            isUseBigAvatar: false,
            avatarWidth: avatarWidth,
            avatarHeight: avatarHeight,
            avatar: matchedUser.user.avatar,
          ),
        ).padding(horizontal: 15),
      ],
    );

final dashboardMatchedUserWidgetActionsContainer = (
  BuildContext context,
  String? sendMessage,
  Function sendMessageCallback,
  String? keepPlayingMessage,
  Function keepPlayingCallback,
) =>
    Styled.widget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // send message button
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SkMobileFont.ic_match_send_message,
                      color: AppSettingsService.themeCommonIconLightColor,
                      size: 28,
                    ).paddingDirectional(
                      start: 18,
                      end: 8,
                    ),
                    Expanded(
                      child: Text(
                        sendMessage!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      )
                          .textColor(
                            AppSettingsService
                                .themeCommonMatchedUserButtonTextColor,
                          )
                          .textAlignment(TextAlign.center)
                          .fontSize(18)
                          .padding(
                            all: 5,
                          ),
                    ),
                  ],
                ).paddingDirectional(end: 48),
              ),
            ],
          )
              .decorated(
                borderRadius: BorderRadius.circular(64),
                color: AppSettingsService
                    .themeCustomMatchedSendMessageButtonBackgroundColor,
              )
              .constrained(
                minHeight: 46,
              )
              .padding(bottom: 15)
              .gestures(
                onTap: () => sendMessageCallback(),
              ),
          // keep play button
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SkMobileFont.ic_match_keep_play,
                      color: AppSettingsService.themeCommonIconLightColor,
                      size: 26,
                    ).paddingDirectional(
                      start: 18,
                      end: 8,
                    ),
                    Expanded(
                      child: Text(
                        keepPlayingMessage!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      )
                          .textColor(
                            AppSettingsService
                                .themeCommonMatchedUserButtonTextColor,
                          )
                          .textAlignment(TextAlign.center)
                          .fontSize(18)
                          .padding(
                            all: 5,
                          ),
                    ),
                  ],
                ).paddingDirectional(end: 44),
              ),
            ],
          )
              .decorated(
                borderRadius: BorderRadius.circular(64),
                border: Border.all(
                  color: AppSettingsService
                      .themeCommonMatchedUserButtonBorderColor,
                  width: 2,
                ),
              )
              .constrained(
                minHeight: 46,
              )
              .gestures(
                onTap: () => keepPlayingCallback(),
              ),
        ],
      ),
    ).constrained(
      width: MediaQuery.of(context).size.width * 0.58,
      minWidth: 220,
      maxWidth: 300,
    );
