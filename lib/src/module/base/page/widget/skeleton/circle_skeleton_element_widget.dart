import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';

class CircleSkeletonElementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container().decorated(
      color: AppSettingsService.themeCommonSkeletonColor,
      shape: BoxShape.circle,
    );
  }
}
