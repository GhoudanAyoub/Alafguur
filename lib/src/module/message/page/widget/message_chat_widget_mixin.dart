import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../state/message_state.dart';

final serviceLocator = GetIt.instance;

mixin MessageChatWidgetMixin on NavigationWidgetMixin {
  void showProfilePage(
    BuildContext context,
    MessageState state,
  ) {
    // don't open the profile page twice it takes a lot of resources
    if (state.isPrevPageProfile) {
      Navigator.pop(context);

      return;
    }

    redirectToProfilePage(
      context,
      state.profile!.id,
      arguments: {
        'isPrevPageMessages': true,
      },
    );
  }
}
