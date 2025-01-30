import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';

final verifyPhoneWidgetWrapperContainer = (
  BuildContext context,
  Widget child,
) =>
    SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: child,
          ),
        ],
      ),
    );

final verifyPhoneWidgetFormContainer =
    (Widget child) => Styled.widget(child: child).width(220);

final verifyPhoneWidgetFormInputContainer =
    (Widget child) => Styled.widget(child: child).decorated(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppSettingsService.themeCommonDividerColor,
            ),
          ),
        );
final verifyPhoneWidgetButtonContainer = (
  BuildContext context,
  String title,
  Function clickCallback,
) =>
    Styled.widget(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppSettingsService.themeCommonAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
        ),
        child: Text(
          LocalizationService.of(context).t(title),
        ).fontSize(18),
        onPressed: clickCallback as void Function()?,
      ),
    ).width(double.infinity).height(48).padding(top: 32, bottom: 26);

final verifyPhoneWidgetTextButtonContainer = (
  BuildContext context,
  Function clickCallback,
  String title,
) =>
    Styled.widget(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppSettingsService.themeCommonAccentColor,
        ),
        child: Text(
          LocalizationService.of(context).t(
            title,
          ),
          textAlign: TextAlign.center,
        ).fontSize(18).padding(bottom: 20, horizontal: 16),
        onPressed: clickCallback as void Function()?,
      ),
    );
