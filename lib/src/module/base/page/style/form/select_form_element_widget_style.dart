import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../widget/form/form_builder_widget.dart';

final selectFormElementDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

final selectFormElementContainer =
    (Widget formElement) => formElement.padding(top: 8, bottom: 8);

final selectFormElementLabelTextContainer = (
  String? message,
  Color? labelColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(labelColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!);

final selectFormElementSelectedValuesContainer = (
  BuildContext context,
  String? values,
  Color? textColor,
  double? fontSize,
) =>
    Container(
      child: Text(
        values!,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ).textColor(textColor!).fontSize(fontSize!).padding(top: 8),
    );

final selectFormElementPopupLabelContainer = (
  String? label,
) =>
    <Widget>[
      PlatformWidget(
        material: (_, __) => Text(label!)
            .fontWeight(FontWeight.bold)
            .alignment(AlignmentDirectional.centerStart)
            .padding(
              horizontal: 24,
              top: 24,
              bottom: 20,
            ),
        cupertino: (_, __) =>
            Text(label!).textColor(AppSettingsService.themeCommonTextColor),
      ),
      PlatformWidget(
        material: (_, __) => Styled.widget().decorated(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppSettingsService.themeCommonDividerColor,
            ),
          ),
        ),
      )
    ].toColumn();

final selectFormDialogContentWrapperContainer =
    (Widget child) => PlatformWidget(
          material: (_, __) => child
              .padding(
                horizontal: 16,
              )
              .decorated(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: AppSettingsService.themeCommonDividerColor,
                  ),
                ),
              ),
          cupertino: (_, __) => child,
        );
