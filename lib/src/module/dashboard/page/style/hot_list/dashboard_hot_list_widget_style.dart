import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/loading_spinner_widget.dart';
import '../../../../base/service/localization_service.dart';

final dashboardHotListWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(child: child)
        .padding(
          horizontal: 12,
          vertical: 16,
        )
        .backgroundColor(AppSettingsService.themeCommonHotListBackgroundColor)
        .width(double.infinity);

final dashboardHotListWidgetAddToListButtonContainer = (
  BuildContext context,
  String title,
  Function clickCallback,
  bool showSpinner,
) =>
    Positioned(
      bottom: 16,
      child: Container(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0), backgroundColor: transparentColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64.0),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocalizationService.of(context).t(title),
                ).fontSize(18),
                if (showSpinner) LoadingSpinnerWidget(),
              ],
            ),
          )
              .decorated(
                gradient: LinearGradient(
                  colors: [
                    AppSettingsService.themeCommonGradientStartColor,
                    AppSettingsService.themeCommonGradientEndColor
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(64.0),
              )
              .height(48),
          onPressed: clickCallback as void Function()?,
        ),
      ),
    );
