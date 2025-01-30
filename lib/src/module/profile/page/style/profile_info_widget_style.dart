import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final profilePageInfoNameContainer = (
  String? name,
) =>
    Text(name!)
        .textColor(
          AppSettingsService.themeCommonTextColor,
        )
        .fontSize(20);

final profilePageInfoAgeContainer = (
  String age,
) =>
    Text(age)
        .textColor(
          AppSettingsService.themeCommonTextColor,
        )
        .fontSize(20);

final Widget Function({Widget child}) profilePageInfoOnlineContainer = ({
  Widget? child,
}) =>
    Icon(
      Icons.fiber_manual_record,
      color: AppSettingsService.themeCommonUserCardOnlineColor,
      size: 14,
    ).padding(
      top: 2,
      horizontal: 3,
    );

final profilePageInfoMoreContainer = (
  Function clickCallBack,
) =>
    SizedBox(
      height: 30,
      child: PlatformIconButton(
        onPressed: clickCallBack as void Function()?,
        materialIcon: Icon(
          Icons.more_vert,
          size: 30,
          color: AppSettingsService.themeCommonProfileInfoMoreIconColor,
        ),
        cupertinoIcon: Icon(
          CupertinoIcons.ellipsis_vertical,
          color: AppSettingsService.themeCommonProfileInfoMoreIconColor,
          size: 30,
        ),
        padding: EdgeInsets.all(1.0),
      ),
    );

final profilePageInfoDistanceWrapperContainer = (
  Widget child,
) =>
    child.padding(
      top: 4,
    );
