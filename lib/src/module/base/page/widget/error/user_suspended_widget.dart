import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../style/common_widget_style.dart';
import '../navigation_widget_mixin.dart';

class UserSuspendedWidget extends StatelessWidget with NavigationWidgetMixin {
  final Map? exceptionResponseBody;

  const UserSuspendedWidget({
    Key? key,
    this.exceptionResponseBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      body: blankBasedPageContainer(
        context,
        <Widget>[
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_alert,
            119,
            colorIcon: AppSettingsService.themeCommonAlertIconColor,
          ),
          // a title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('profile_suspended'),
          ),
          // a suspended reason
          if (_isSuspendedReasonNotEmpty())
            blankBasedPageDescrContainer(
              exceptionResponseBody!['description'],
            ),
        ].toColumn(),
        backToStarterCallback: () => redirectToMainPage(
          context,
          cleanAuthCredentials: true,
        ),
      ),
    );
  }

  bool _isSuspendedReasonNotEmpty() {
    return exceptionResponseBody != null &&
        exceptionResponseBody!['description'] != null;
  }
}
