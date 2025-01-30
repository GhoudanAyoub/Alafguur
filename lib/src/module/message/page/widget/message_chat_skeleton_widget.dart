import 'package:flutter/material.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../style/message_chat_skeleton_widget_style.dart';

class MessageChatSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return messageChatSkeletonWidgetWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1st bubble
          BarSkeletonElementWidget(
            paddingBottom: 35,
            width: MediaQuery.of(context).size.width * 0.47,
            height: 90,
            children: [
              BarSkeletonElementWidget(
                width: 97,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
              BarSkeletonElementWidget(
                width: 61,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
              BarSkeletonElementWidget(
                width: 76,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
            ],
          ),

          // 2nd bubble
          BarSkeletonElementWidget(
            paddingBottom: 35,
            width: MediaQuery.of(context).size.width * 0.36,
            height: 90,
            children: [
              BarSkeletonElementWidget(
                width: 67,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
              BarSkeletonElementWidget(
                width: 42,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
              BarSkeletonElementWidget(
                width: 53,
                height: 10,
                paddingLeft: 15,
                paddingRight: 15,
                background: AppSettingsService.themeCommonScaffoldLightColor,
              ),
            ],
          ),

          // 3rd bubble
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BarSkeletonElementWidget(
                paddingBottom: 35,
                width: MediaQuery.of(context).size.width * 0.7,
                height: 110,
                children: [
                  BarSkeletonElementWidget(
                    width: 146,
                    height: 10,
                    paddingLeft: 15,
                    paddingRight: 15,
                    background:
                        AppSettingsService.themeCommonScaffoldLightColor,
                  ),
                  BarSkeletonElementWidget(
                    width: 92,
                    height: 10,
                    paddingLeft: 15,
                    paddingRight: 15,
                    background:
                        AppSettingsService.themeCommonScaffoldLightColor,
                  ),
                  BarSkeletonElementWidget(
                    width: 115,
                    height: 10,
                    paddingLeft: 15,
                    paddingRight: 15,
                    background:
                        AppSettingsService.themeCommonScaffoldLightColor,
                  ),
                  BarSkeletonElementWidget(
                    width: 62,
                    height: 10,
                    paddingLeft: 15,
                    paddingRight: 15,
                    background:
                        AppSettingsService.themeCommonScaffoldLightColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
