import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../service/model/dashboard_matched_user_model.dart';
import 'dashboard_conversation_widget_style.dart';

final dashboardConversationWidgetMatchedUsersWrapperContainer =
    (Widget widget) => widget.height(120).padding(
          horizontal: 16,
        );

Widget dashboardConversationWidgetMatchedUserItemContainer(
  DashboardMatchedUserModel matchedUser,
  Function clickCallback,
  BuildContext context, {
  double avatarWidth = 80,
  double avatarHeight = 80,
}) {
  bool isRtlModeActive = isRtlMode(context);
  return SizedBox(
    width: 80,
    child: Column(
      children: [
        // a user avatar
        Stack(
          children: [
            ClipOval(
              child: UserAvatarWidget(
                isUseBigAvatar: false,
                avatarHeight: avatarHeight,
                avatarWidth: avatarWidth,
                avatar: matchedUser.user.avatar,
              ),
            ).padding(bottom: 8),
            // a new flag
            if (matchedUser.isNew)
              dashboardConversationWidgetNotificationContainer(
                context,
              )
          ],
        ),

        // a user name
        Text(
          matchedUser.user.userName!,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          maxLines: 1,
        )
            .textColor(AppSettingsService.themeCommonTextColor)
            .fontSize(16)
            .fontWeight(FontWeight.w500),
      ],
    ).gestures(onTap: () => clickCallback()),
  ).padding(
    right: !isRtlModeActive ? 18 : 0,
    left: isRtlModeActive ? 18 : 0,
  );
}
