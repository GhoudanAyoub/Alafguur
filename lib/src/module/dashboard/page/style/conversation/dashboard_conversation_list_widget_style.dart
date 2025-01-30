import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../service/model/dashboard_conversation_model.dart';
import 'dashboard_conversation_widget_style.dart';

final dashboardConversationWidgetConversationsWrapperContainer =
    (Widget child) => Styled.widget(
          child: child,
        )
            .padding(
              horizontal: 16,
              top: 16,
            )
            .backgroundColor(
              AppSettingsService
                  .themeCustomDashboardConversationListBackgroundColor,
            );

Widget dashboardConversationWidgetConversationsItemContainer(
  DashboardConversationModel conversation,
  Function clickCallback,
  Function longClickCallback,
  BuildContext context, {
  double avatarWidth = 80,
  double avatarHeight = 80,
}) {
  bool isRtlModeActive = isRtlMode(context);
  return Opacity(
    opacity: conversation.user.isBlocked! ? 0.5 : 1,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // a user avatar
        Stack(
          children: [
            ClipOval(
              child: UserAvatarWidget(
                isUseBigAvatar: false,
                avatarHeight: avatarHeight,
                avatarWidth: avatarWidth,
                avatar: conversation.user.avatar,
              ),
            ),
            // a new flag
            if (conversation.isNew)
              dashboardConversationWidgetNotificationContainer(
                context,
              )
          ],
        ).padding(
          right: !isRtlModeActive ? 16 : 0,
          left: isRtlModeActive ? 16 : 0,
        ),
        // a user name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.user.userName!)
                  .textColor(AppSettingsService.themeCommonTextColor)
                  .fontSize(15)
                  .fontWeight(FontWeight.w500)
                  .padding(
                    top: 16,
                    bottom: 3,
                  ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // a message received icon
                  if (conversation.isReply && conversation.isOpponentRead)
                    Icon(
                      Icons.done_all,
                      color: AppSettingsService.themeCommonAccentColor,
                      size: 18,
                    ).padding(
                      right: !isRtlModeActive ? 5 : 0,
                      left: isRtlModeActive ? 5 : 0,
                    ),

                  // a message sent icon
                  if (conversation.isReply && !conversation.isOpponentRead)
                    Icon(
                      Icons.done,
                      color: AppSettingsService.themeCommonAccentColor,
                      size: 18,
                    ).padding(
                      right: !isRtlModeActive ? 2 : 0,
                      left: isRtlModeActive ? 2 : 0,
                    ),

                  // a preview message
                  Expanded(
                    child: Text(
                      conversation.previewText.replaceAll('\n', ' '),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ).textColor(AppSettingsService
                        .themeCustomDashboardConversationListPreviewTextColor),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    ).backgroundColor(
      transparentColor(),
    ),
  )
      .gestures(
        onTap: () => clickCallback(),
        onLongPress: () => longClickCallback(),
      )
      .padding(bottom: 16);
}
