import 'package:flutter/widgets.dart';

import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../style/settings_page_skeleton_widget_style.dart';

class SettingsPageSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return settingsPageSkeletonWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarSkeletonElementWidget(
            width: 100,
            height: 10,
            paddingLeft: 21,
            paddingRight: 21,
          ),
          ListSkeletonWidget(
            listPaddingTop: 0,
            barsCount: 2,
          ),
          BarSkeletonElementWidget(
            width: 100,
            height: 10,
            paddingLeft: 21,
            paddingRight: 21,
          ),
          ListSkeletonWidget(
            listPaddingTop: 0,
            barsCount: 2,
          ),
        ],
      ),
    );
  }
}
