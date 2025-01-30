import 'package:flutter/material.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/service/localization_service.dart';

class DashboardConversationListEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_chat,
            113,
          ),
          // a title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('conversations_empty_title'),
          ),
          // a desc
          blankBasedPageDescrContainer(
            LocalizationService.of(context).t('conversations_empty_descr'),
          ),
        ],
      ),
    );
  }
}
