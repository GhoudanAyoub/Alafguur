import 'package:mobx/mobx.dart';

import '../../service/match_action_service.dart';

part 'match_action_state.g.dart';

class MatchActionState = _MatchActionState with _$MatchActionState;

abstract class _MatchActionState with Store {
  final MatchActionService matchActionService;

  _MatchActionState({
    required this.matchActionService,
  });

  bool? get isUserLikePressed => matchActionService.isUserLikePressed;

  Future<void> likeUser(int userId) {
    setIsUserLikePressed(true);
    return matchActionService.likeUser(userId);
  }

  void setIsUserLikePressed(bool value) =>
      matchActionService.setIsUserLikePressed(value);

  bool? get isUserDisLikePressed => matchActionService.isUserDisLikePressed;

  void setIsUserDisLikePressed(bool value) =>
      matchActionService.setIsUserDisLikePressed(value);

  Future<void> dislikeUser(int userId) {
    setIsUserDisLikePressed(true);
    return matchActionService.dislikeUser(userId);
  }

  Future<void> deleteMatch(int userId) {
    return matchActionService.deleteMatch(userId);
  }
}
