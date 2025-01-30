import 'package:flutter/material.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/service/localization_service.dart';
import '../../style/conversation/dashboard_conversation_search_empty_widget_style.dart';

class DashboardConversationSearchEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return dashboardConversationSearchEmptyWidgetWrapperContainer(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_not_found,
            75,
          ),
          // a title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('conversations_no_results'),
          ),
        ],
      ),
    );
  }
}
