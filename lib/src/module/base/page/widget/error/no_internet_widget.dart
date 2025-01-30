import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/root_state.dart';
import '../../style/common_widget_style.dart';
import '../navigation_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class NoInternetWidget extends StatefulWidget with NavigationWidgetMixin {
  const NoInternetWidget({
    Key? key,
  }) : super(key: key);

  @override
  _NoInternetWidgetState createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  late final RootState _state;
  Timer? pingTimer;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<RootState>();
    _state.setOnlineCallback(_onOnline());

    WidgetsBinding.instance.addPostFrameCallback((_) => runPing());
  }

  @override
  void dispose() {
    if (pingTimer != null) {
      pingTimer!.cancel();
    }

    _state.setOnlineCallback(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      body: blankBasedPageContainer(
        context,
        blankBasedPageContentWrapperContainer(
          <Widget>[
            // an icon
            blankBasedPageImageContainer(
              SkMobileFont.ic_no_internet,
              194,
              colorIcon: AppSettingsService.themeCommonDangerousColor,
            ),
            // no internet title
            blankBasedPageTitleContainer(_pageTitle),
            // no internet desc
            blankBasedPageDescrContainer(_pageDesc),
          ].toColumn(),
        ),
      ),
    );
  }

  OnOnlineCallback _onOnline() {
    return (bool isOnline) async {
      if (isOnline) {
        await _handleOnlineStatus();
      }
    };
  }

  Future<void> runPing() async {
    pingTimer = Timer.periodic(
      Duration(seconds: 10),
      (_) async {
        try {
          await _state.ping();
          await _handleOnlineStatus();
        } catch (error) {}
      },
    );
  }

  Future<void> _handleOnlineStatus() async {
    // load necessary bootstrap resources
    if (!_state.isApplicationLoaded) {
      await Future.wait([
        _state.loadResources(),
        LocalizationService.of(context).loadTranslations(null)
      ]);

      _state.isApplicationLoaded = true;
    }

    _state.restartServerUpdates();

    widget.redirectToMainPage(context, cleanAppErrors: true);
  }

  String get _pageTitle {
    return _state.isApplicationLoaded
        ? LocalizationService.of(context).t(
            'no_internet_title',
          )
        : 'Connection Error';
  }

  String get _pageDesc {
    return _state.isApplicationLoaded
        ? LocalizationService.of(context).t(
            'no_internet',
          )
        : 'No internet connection';
  }
}
