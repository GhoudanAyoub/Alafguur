import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flag_content_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/user_distance_widget.dart';
import '../state/profile_state.dart';
import '../style/profile_info_widget_style.dart';
import 'profile_action_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class ProfileInfoWidget extends StatelessWidget
    with
        ActionSheetWidgetMixin,
        ModalWidgetMixin,
        FlagContentWidgetMixin,
        FlushbarWidgetMixin,
        ProfileActionWidgetMixin {
  final ProfileState state;

  const ProfileInfoWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return infoItemContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // a user's name
                    Flexible(
                      fit: FlexFit.loose,
                      child:
                          profilePageInfoNameContainer(state.profile!.userName),
                    ),
                    // a user's age
                    if (state.profile!.age != null)
                      profilePageInfoAgeContainer(
                        ', ' + state.profile!.age.toString(),
                      ),
                    // a user's online status
                    if (state.profile!.isOnline!)
                      profilePageInfoOnlineContainer(),
                  ],
                ),
                // a user's distance
                if (!state.isProfileOwner && state.profile!.distance != null)
                  profilePageInfoDistanceWrapperContainer(
                    UserDistanceWidget(
                      userModel: state.profile,
                    ),
                  )
              ],
            ),
          ),
          // extra actions
          if (!state.isProfileOwner)
            profilePageInfoMoreContainer(
              () => showProfileActions(context, state),
            ),
        ],
      ),
      context,
    );
  }
}
