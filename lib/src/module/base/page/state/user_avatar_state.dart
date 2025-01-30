import 'package:mobx/mobx.dart';

import 'root_state.dart';

part 'user_avatar_state.g.dart';

class UserAvatarState = _UserAvatarState with _$UserAvatarState;

abstract class _UserAvatarState with Store {
  final RootState rootState;

  _UserAvatarState({
    required this.rootState,
  });

  String getFallbackAvatar(bool isBigAvatar) {
    if (isBigAvatar) {
      return getBigDefaultAvatar();
    }

    return getDefaultAvatar();
  }

  String getDefaultAvatar() {
    return rootState.getSiteSetting('defaultAvatar', '');
  }

  String getBigDefaultAvatar() {
    return rootState.getSiteSetting('bigDefaultAvatar', '');
  }
}
