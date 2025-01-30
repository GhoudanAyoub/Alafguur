import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../../app/service/model/route_model.dart';
import '../../admob/page/widget/admob_banner_widget.dart';
import '../root_page_bootstrapper.dart';
import '../utility/theme_utility.dart';
import 'error_page.dart';
import 'state/root_state.dart';

class RootPage extends StatefulWidget {
  final List<RouteModel> _registeredRoutes = [];

  void setRegisteredRoutes(List<RouteModel> registeredRoutes) {
    _registeredRoutes.addAll(registeredRoutes);
  }

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<RootPage> with WidgetsBindingObserver {
  late final RootPageBootstrapper _bootstrapper;
  late final RootState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<RootState>();
    _state.setErrorCallback(_onErrorCallback());
    _bootstrapper = GetIt.instance.get<RootPageBootstrapper>();
    WidgetsBinding.instance.addObserver(this);

    _state.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state.applicationState = state;
  }

  @override
  void didChangePlatformBrightness() {
    AppSettingsService.setDarkMode(isDarkMode());

    // refresh all the widgets
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      initialPlatform: _bootstrapper.getInitialPlatform(),
      builder: (BuildContext context) => PlatformApp(
        title: _bootstrapper.getAppTitle(),
        debugShowCheckedModeBanner: false,
        initialRoute: _bootstrapper.getInitialRoute(),
        onGenerateRoute:
            _bootstrapper.initRouter(widget._registeredRoutes).generator,
        localizationsDelegates: [
          _bootstrapper.getLocalizationDelegate(),
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        navigatorObservers: _bootstrapper.getNavigatorObservers(),
        navigatorKey: _state.navigatorKey,
        material: (_, __) => getAndroidTheme(),
        cupertino: (_, __) => getIosTheme(),
        builder: (BuildContext context, Widget? requestedWidget) {
          return Column(
            children: <Widget>[
              Expanded(
                child: requestedWidget!,
              ),
              AdmobBannerWidget(),
            ],
          );
        },
        localeResolutionCallback: _bootstrapper.getLocaleResolutionCallback(),
      ),
    );
  }

  OnErrorCallback _onErrorCallback() {
    return (dynamic error) {
      // redirect to the error page
      _state.navigatorKey.currentState!.pushAndRemoveUntil(
        platformPageRoute(
          builder: (context) => ErrorPage(
            error: _state.error,
            stackTrace: _state.stackTrace,
            isAppLoaded: _state.isApplicationLoaded,
          ),
          context: _state.navigatorKey.currentState!.context,
        ),
        (Route<dynamic> route) => false,
      );
    };
  }
}
