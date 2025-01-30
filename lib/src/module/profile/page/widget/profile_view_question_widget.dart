import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../state/profile_state.dart';

final serviceLocator = GetIt.instance;

class ProfileViewQuestionWidget extends StatelessWidget {
  final ProfileState state;

  const ProfileViewQuestionWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getProfileViewQuestions(context),
    );
  }

  List<Widget> _getProfileViewQuestions(BuildContext context) {
    final List<Widget> info = [];
    final latestSectionIndex = state.profile!.viewQuestions!.length - 1;

    state.profile!.viewQuestions!.asMap().forEach(
      (sectionIndex, viewQuestion) {
        final latestItemsIndex = viewQuestion.items.length - 1;

        viewQuestion.items.asMap().forEach(
          (itemIndex, viewQuestionItem) {
            info.add(
              infoItemContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoItemLabelContainer(viewQuestionItem.label),
                    infoItemValueContainer(viewQuestionItem.value),
                  ],
                ),
                context,
                displayBorder: latestSectionIndex == sectionIndex &&
                        latestItemsIndex == itemIndex
                    ? false
                    : true,
              ),
            );
          },
        );
      },
    );

    return info;
  }
}
