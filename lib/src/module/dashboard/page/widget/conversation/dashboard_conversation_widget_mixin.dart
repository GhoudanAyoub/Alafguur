import 'package:get_it/get_it.dart';

import '../../../../base/service/model/user_model.dart';
import '../../state/dashboard_conversation_state.dart';

mixin DashboardConversationWidgetMixin {
  bool isChatAllowed(
    UserModel? profile
  ) {
    return _getState()!.isChatAllowed(profile);
  }

  DashboardConversationState? _getState() {
    return GetIt.instance<DashboardConversationState>();
  }
}
