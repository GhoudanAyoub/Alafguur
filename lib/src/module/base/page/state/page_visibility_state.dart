import 'package:mobx/mobx.dart';

import '../../../../app/utility/fake_dart_html_utility.dart'
    if (dart.library.html) 'dart:html' show document;

part 'page_visibility_state.g.dart';

enum PageVisibility {
  visible,
  hidden,
  prerender,
  unloaded,
  unknown,
}

typedef OnVisibilityChangeCallback = void Function();

class PageVisibilityState = _PageVisibilityState with _$PageVisibilityState;

/// Encapsulates page visibility state change handling.
abstract class _PageVisibilityState with Store {
  /// Browser event name.
  final _visibilityChangeEventName = 'visibilitychange';

  @observable
  PageVisibility visibility = PageVisibility.unknown;

  /// Initialize state.
  void init() {
    _onVisibilityChange(null);
    document.addEventListener(_visibilityChangeEventName, _onVisibilityChange);
  }

  /// Page visibility change callback. Called every time page visibility
  /// changes.
  ///
  /// Retrieves native visibility value, translates it into one of the
  /// [PageVisibility] members and assigns the result to the [visibility]
  /// observable.
  @action
  void _onVisibilityChange(_) {
    final nativeVisibility = document.visibilityState;

    switch (nativeVisibility) {
      case 'visible':
        visibility = PageVisibility.visible;
        break;

      case 'hidden':
        visibility = PageVisibility.hidden;
        break;

      case 'prerender':
        visibility = PageVisibility.prerender;
        break;

      case 'unloaded':
        visibility = PageVisibility.unloaded;
        break;

      default:
        visibility = PageVisibility.unknown;
        break;
    }
  }
}
