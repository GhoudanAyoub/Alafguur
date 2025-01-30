import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/service/localization_service.dart';
import '../state/profile_state.dart';

final serviceLocator = GetIt.instance;

class ProfileCompatibilityWidget extends StatelessWidget {
  final ProfileState state;

  const ProfileCompatibilityWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return infoItemContainer(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          infoItemLabelContainer(
              LocalizationService.of(context).t('compatibility')),
          profileCompatibilityBarSectionContainer(
            context,
            state.profile!.compatibility.toString(),
            state.profile!.compatibility!.toDouble(),
          ),
        ],
      ),
      context,
    );
  }
}
