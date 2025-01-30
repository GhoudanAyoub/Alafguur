import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/state/root_state.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import '../../join/join_config.dart';
import '../../reset_password/reset_password_config.dart';
import 'state/login_state.dart';
import 'style/login_page_style.dart';

class LoginPage extends AbstractPage {
  final bool clearCredentials;

  const LoginPage({
    Key? key,
    this.clearCredentials = false,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  late final LoginState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<LoginState>();
    _formBuilderWidget = GetIt.instance.get<FormBuilderWidget>();

    // register form elements
    _formBuilderWidget.registerFormElements(_state.getFormElements());

    // apply a custom form renderer
    _formBuilderWidget.registerFormRenderer(loginPageFormRenderer());

    // apply a custom theme for the form
    _formBuilderWidget.registerFormTheme(loginPageFormTheme());

    _state.setDeeplinkCallback(_onDeepLink());

    _state.init();

    // clear the credentials once the page is displayed
    if (widget.clearCredentials) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _state.clearCredentials());
    }

    // pwa auth handler
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_state.isPwaLoginAttempted()) {
        return;
      }

      final pwaAuthenticatedProviderId =
          await _state.getPwaAuthenticatedProviderId();

      _firebaseAuthFinalize(
          pwaAuthenticatedProviderId != null, pwaAuthenticatedProviderId);
    });
  }

  @override
  void dispose() {
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        useSafeArea: false,
        //scrollable: true,
        disableContent: _state.loading || _state.firebaseLoading,
        body: LayoutBuilder(builder: (
          BuildContext context,
          BoxConstraints viewportConstraints,
        ) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: loginPageWrapperContainer(
                customBackground: _state.customBackground,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // a logo
                    loginPageLogoContainer(
                      customLogoWidth: _state.customLogoWidth,
                      customLogo: _state.customLogo,
                    ),
                    loginPageBodyContainer(
                      context,
                      child: Column(
                        children: [
                          //login form
                          _formBuilderWidget,
                          // login inline buttons
                          loginPageInlineButtonWrapperContainer(
                            child: <Widget>[
                              // login forgot pass
                              loginPageInlineButtonContainer(
                                LocalizationService.of(context)
                                    .t('forgot_password'),
                              ).gestures(
                                onTap: _pushResetPasswordPage,
                              ),
                              // login join
                              loginPageInlineButtonContainer(
                                LocalizationService.of(context).t('sign_up'),
                              ).gestures(
                                onTap: _pushJoinInitialPage,
                              )
                            ].toRow(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                          // login  button
                          loginPageLoginButtonContainer(
                            LocalizationService.of(context).t('login'),
                            () => _authenticate(),
                            _state.loading,
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        // login or via connect label
                        if (_state.isCustomSignInAllowed())
                          <Widget>[
                            // firebase label
                            loginPageFirebaseLabelWrapperContainer(
                              LocalizationService.of(context)
                                  .t('facebook_connect_login_label'),
                            ),
                            // firebase buttons
                            loginPageFirebaseButtonsContainer(
                              child: <Widget>[
                                if (_state.isGoogleSignInAllowed())
                                  // login firebase google
                                  loginPageFirebaseButtonGoogleContainer()
                                      .gestures(
                                    onTap: _googleSignIn,
                                  ),
                                // TODO: replace flutter_twitter_login
                                // if (_state.isTwitterSignInAllowed())
                                //   // login firebase twitter
                                //   loginPageFirebaseButtonTwitterContainer()
                                //       .gestures(
                                //     onTap: _twitterSignIn,
                                //   ),
                                if (_state.isFacebookSignInAllowed())
                                  // login firebase fb
                                  loginPageFirebaseButtonFbContainer().gestures(
                                    onTap: _faceBookSignIn,
                                  ),
                                if (_state.isAppleSignInAllowed())
                                  // login firebase apple
                                  loginPageFirebaseButtonAppleContainer()
                                      .gestures(
                                    onTap: _appleSignIn,
                                  ),
                              ].toRow(
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ),
                          ].toColumn(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  OnDeepLinkCallback _onDeepLink() {
    return (String? link) {
      if (link == null) {
        return;
      }

      final verifyCodeUrl =
          widget.processUrlArguments(RESET_PASSWORD_VERIFY_URL, [
        'code',
      ], [
        '',
      ]);

      if (widget.isPageActive(verifyCodeUrl) ||
          (!widget.isResetPasswordLink(link) &&
              !widget.isResetRequestPasswordLink(link))) {
        return;
      }

      // open the reset password page
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(
          context,
          verifyCodeUrl,
        );
      });
    };
  }

  /// Push reset password page onto the nav stack
  void _pushResetPasswordPage() {
    // Navigator.
    Navigator.pushNamed(context, RESET_PASSWORD_MAIN_URL);
  }

  /// Push join initial page onto the nav stack
  void _pushJoinInitialPage() {
    Navigator.pushNamed(context, JOIN_MAIN_URL);
  }

  /// authenticate
  Future<void> _authenticate() async {
    // validate and authenticate
    bool isFormValid = await _formBuilderWidget.isFormValid();

    if (isFormValid) {
      final isAuthenticated = await _state.authenticate(
        _formBuilderWidget.getFormValues(),
      );

      if (!isAuthenticated) {
        widget.showMessage('login_failed', context);

        return;
      }

      widget.hideKeyboard();
      widget.logLogin();
      widget.redirectToMainPage(context);
    }
  }

  void _googleSignIn() async {
    _firebaseAuthFinalize(await _state.googleSignIn(), 'google');
  }

  // TODO: replace flutter_twitter_login
  // void _twitterSignIn() async {
  //   _firebaseAuthFinalize(await _state.twitterSignIn(), 'twitter');
  // }

  void _faceBookSignIn() async {
    _firebaseAuthFinalize(await _state.faceBookSignIn(), 'facebook');
  }

  void _appleSignIn() async {
    _firebaseAuthFinalize(await _state.appleSignIn(), 'apple');
  }

  void _firebaseAuthFinalize(bool? isAuthenticated, String? method) {
    if (isAuthenticated == null) {
      return;
    }

    if (isAuthenticated && method != null) {
      widget.logLogin(loginMethod: method);
      widget.redirectToMainPage(context);

      return;
    }

    widget.showMessage('firebaseauth_authenticate_error', context);
  }
}
