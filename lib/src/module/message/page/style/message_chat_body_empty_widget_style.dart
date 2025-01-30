import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../base/page/widget/user_avatar_widget.dart';
import '../../../base/service/model/user_avatar_model.dart';

final messageChatBodyEmptyWidgetAvatarContainer = (
  UserAvatarModel? avatar,
  Function clickCallback,
) =>
    ClipOval(
      child: UserAvatarWidget(
        isUseBigAvatar: false,
        avatarHeight: 160,
        avatarWidth: 160,
        avatar: avatar,
      ),
    )
        .alignment(
          Alignment.center,
        )
        .padding(
          bottom: 15,
        )
        .gestures(
          onTap: () => clickCallback(),
        );
