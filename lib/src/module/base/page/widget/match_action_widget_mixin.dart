import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../service/localization_service.dart';
import '../state/match_action_state.dart';
import 'modal_widget_mixin.dart';

mixin MatchActionWidgetMixin on ModalWidgetMixin {
  /// delete a created match
  void deleteMatch(int userId) {
    _getState().deleteMatch(userId);
  }

  // like a user
  void likeUser(
    int id,
    String? name,
    BuildContext context,
    Function likeCallback, {
    Function? cancelCallback,
  }) {
    final state = _getState();

    if (state.isUserLikePressed == true) {
      state.likeUser(id);
      likeCallback();

      return;
    }

    final message = LocalizationService.of(context).t(
      'like_confirmation',
      searchParams: ['name'],
      replaceParams: [name!],
    );

    showConfirmation(
      context,
      message,
      () {
        state.likeUser(id);
        likeCallback();
      },
      dismissible: false,
      yesLabel: 'ok',
      noLabel: 'cancel',
      translate: false,
      cancelCallback: () {
        state.setIsUserLikePressed(true);
        cancelCallback?.call();
      },
    );
  }

  /// dislike a user
  void dislikeUser(
    int id,
    String name,
    BuildContext context,
    Function dislikeCallback, {
    Function? cancelCallback,
  }) {
    final state = _getState();

    if (state.isUserDisLikePressed == true) {
      state.dislikeUser(id);
      dislikeCallback();

      return;
    }

    final message = LocalizationService.of(context).t(
      'dislike_confirmation',
      searchParams: ['name'],
      replaceParams: [name],
    );

    showConfirmation(
      context,
      message,
      () {
        state.dislikeUser(id);
        dislikeCallback();
      },
      dismissible: false,
      yesLabel: 'ok',
      noLabel: 'cancel',
      translate: false,
      cancelCallback: () {
        state.setIsUserDisLikePressed(true);
        cancelCallback?.call();
      },
    );
  }

  MatchActionState _getState() {
    return GetIt.instance.get<MatchActionState>();
  }
}
