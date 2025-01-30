import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/loading_spinner_widget.dart';

final dashboardTinderLocationIssueWidgetButtonContainer = (
  String? title,
  Function clickCallback,
  bool isLoading,
) =>
    Styled.widget(
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title!,
            )
                .fontSize(18)
                .textColor(
                  AppSettingsService.themeCommonHardcodedWhiteColor,
                )
                .padding(horizontal: 8),
            if (isLoading)
              LoadingSpinnerWidget(
                radius: 9,
              ),
          ],
        ),
        onPressed: () => clickCallback(),
      )
          .decorated(
            color: AppSettingsService.themeCommonAccentColor,
            borderRadius: BorderRadius.circular(64.0),
          )
          .constrained(
            minWidth: 200,
          )
          .height(48)
          .padding(
            horizontal: 16,
          ),
    );
