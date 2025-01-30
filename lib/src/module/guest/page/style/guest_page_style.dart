import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

final guestPageWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final guestPageLikeActionContainer = (
  String? label,
  Function clickCallback,
) =>
    userListSlideActionButtonContainer(
      label,
      () => clickCallback(),
      AppSettingsService.themeCommonProfileActionTextColor,
      AppSettingsService.themeCommonProfileAction1Color,
    );

final guestPageSendMessageActionContainer = (
  String? label,
  Function clickCallback,
) =>
    userListSlideActionButtonContainer(
      label,
      () => clickCallback(),
      AppSettingsService.themeCommonProfileActionTextColor,
      AppSettingsService.themeCommonAccentColor,
    );

final guestPageRemoveActionContainer = (
  String? label,
  Function clickCallback,
) =>
    userListSlideActionButtonContainer(
      label,
      () => clickCallback(),
      AppSettingsService.themeCommonProfileActionTextColor,
      AppSettingsService.themeCommonProfileAction2Color,
    );
