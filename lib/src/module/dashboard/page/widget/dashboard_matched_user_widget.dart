import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../../base/service/model/user_model.dart';
import '../../../message/message_config.dart';
import '../../service/model/dashboard_matched_user_model.dart';
import '../state/dashboard_user_state.dart';
import '../style/dashboard_matched_user_widget_style.dart';

class DashboardMatchedUserWidget extends StatelessWidget
    with NavigationWidgetMixin {
  final DashboardMatchedUserModel matchedUser;

  const DashboardMatchedUserWidget({
    Key? key,
    required this.matchedUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      body: dashboardMatchedUserWidgetWrapperContainer(
        Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // a header
                  dashboardMatchedUserWidgetHeaderContainer(
                    LocalizationService.of(context).t(
                      'matched_user_page_header',
                    ),
                    LocalizationService.of(context).t(
                      'matched_user_desc',
                      searchParams: [
                        'userName',
                      ],
                      replaceParams: [
                        matchedUser.user.userName!,
                      ],
                    ),
                  ),

                  // avatars
                  dashboardMatchedUserWidgetAvatarsContainer(
                    _getMe(),
                    matchedUser,
                  ),
                ],
              ),
            ),

            // actions
            Expanded(
              flex: 5,
              child: dashboardMatchedUserWidgetActionsContainer(
                context,
                LocalizationService.of(context).t('send_message'),
                () => _showChatPage(context),
                LocalizationService.of(context).t('keep_playing'),
                () => _keepPlaying(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  UserModel? _getMe() {
    return GetIt.instance<DashboardUserState>().user;
  }

  void _showChatPage(BuildContext context) {
    // close the current window and open the chat page
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [matchedUser.user.id],
      ),
    );
  }

  void _keepPlaying(BuildContext context) {
    Navigator.pop(context);
  }
}
