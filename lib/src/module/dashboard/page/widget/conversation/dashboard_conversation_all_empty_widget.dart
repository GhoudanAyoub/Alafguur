import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/service/localization_service.dart';

class DashboardConversationAllEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return blankBasedPageContentWrapperContainer(
      blankBasedPageContainer(
        context,
        <Widget>[
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_chat,
            113,
          ),
          // a title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('conversations_no_lists_title'),
          ),
          // a description
          blankBasedPageDescrContainer(
            LocalizationService.of(context).t('conversations_no_lists_descr'),
          ),
        ].toColumn(),
      ),
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
    );
  }
}
