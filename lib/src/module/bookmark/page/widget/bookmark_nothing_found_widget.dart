import 'package:flutter/material.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/service/localization_service.dart';
import '../style/bookmark_nothing_found_widget_style.dart';

class BookmarkNothingFoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return bookmarkNothingFoundWidgetWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_not_found,
            75,
          ),
          // a not found title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t(
              'empty_user_listing_header',
            ),
          ),
        ],
      ),
    );
  }
}
