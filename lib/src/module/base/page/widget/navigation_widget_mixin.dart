import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

import '../../base_config.dart';
import '../state/root_state.dart';

mixin NavigationWidgetMixin {
  bool isPageActive(String page) {
    var isActive = false;

    NavigationHistoryObserver().history.forEach((route) {
      if (route.settings.name == page) {
        isActive = true;
      }
    });

    return isActive;
  }

  /// redirect to the main page
  ///
  /// and clean the route stack
  Future<void> redirectToMainPage(
    BuildContext context, {
    bool cleanAuthCredentials = false,
    bool cleanAppErrors = false,
    bool unregisterDevice = true,
  }) {
    if (cleanAuthCredentials) {
      GetIt.instance<RootState>().cleanAuthCredentials(
        unregisterDevice: unregisterDevice,
      );
    }

    if (cleanAppErrors) {
      GetIt.instance<RootState>().cleanAppErrors();
    }

    return Navigator.pushNamedAndRemoveUntil(
      context,
      BASE_MAIN_URL,
      (r) => false,
    );
  }

  /// redirect to the payment page
  Future<void> redirectToPaymentPage(BuildContext context) {
    return Navigator.pushNamed(context, BASE_PAYMENT_URL);
  }

  /// redirect to the profile page
  Future<void> redirectToProfilePage(
    BuildContext context,
    int? userId, {
    Map? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      processUrlArguments(
        BASE_PROFILE_URL,
        ['id'],
        [
          userId,
        ],
      ),
      arguments: arguments,
    );
  }

  // process url arguments
  String processUrlArguments(
    String url,
    List<String> searchParams,
    List<dynamic> replaceParams,
  ) {
    if (searchParams.length != replaceParams.length) {
      throw ArgumentError(
        'There is a difference in the length between "searchParams" and "replaceParams"',
      );
    }

    searchParams.asMap().forEach((index, searchParam) {
      url = url.replaceAll(
        ':' + searchParam,
        replaceParams[index].toString(),
      );
    });

    return url;
  }
}
