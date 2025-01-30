import 'package:get_it/get_it.dart';

import '../state/root_state.dart';

/// Add debug logging functionality to a widget.
mixin DebugLoggerWidgetMixin {
  /// Print a debug [message].
  void debugLog(dynamic message) {
    GetIt.instance.get<RootState>().log(message);
  }
}
