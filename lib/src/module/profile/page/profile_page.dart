import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../payment/page/widget/payment_access_denied_widget.dart';
import 'state/profile_state.dart';
import 'style/profile_page_style.dart';
import 'widget/profile_action_toolbar_widget.dart';
import 'widget/profile_compatibility_widget.dart';
import 'widget/profile_info_widget.dart';
import 'widget/profile_photo_widget.dart';
import 'widget/profile_skeleton_widget.dart';
import 'widget/profile_view_question_widget.dart';

final serviceLocator = GetIt.instance;

class ProfilePage extends AbstractPage {
  const ProfilePage({Key? key, required Map<String, dynamic>? routeParams, required Map<String, dynamic>? widgetParams})
    : super(key: key, routeParams: routeParams, widgetParams: widgetParams);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  late final ProfileState _state;

  bool _isPrevPageMessages = false;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<ProfileState>();

    _state.init(int.parse(widget.routeParams?['id'][0].toString() ?? "0"));

    if (widget.widgetParams!['isPrevPageMessages'] != null) {
      _isPrevPageMessages = true;
    }

    widget.logViewItem(widget.routeParams?['id'][0].toString() ?? "", '', 'profile');
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
        backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
        body: !_state.isPageLoaded || !_state.isProfileLoaded
            ? ProfileSkeletonWidget(isProfileOwner: _state.isProfileOwner)
            : _state.isViewProfileAllowed
            ? _profilePage()
            : PaymentAccessDeniedWidget(
                showBackButton: true,
                showUpgradeButton: _state.permissionViewProfile?.isPromoted == true,
              ),
        // make it scrollable only when the page is loading
        scrollable: !_state.isPageLoaded || !_state.isProfileLoaded,
      ),
    );
  }

  Widget _profilePage() {
    return Column(
      children: [
        // profile info
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // photos
                profilePagePhotosContainer(context, ProfilePhotoWidget(state: _state)),

                // profile info
                ProfileInfoWidget(state: _state),

                // compatibility
                if (!_state.isProfileOwner && _state.isCompatibilityLoaded) ProfileCompatibilityWidget(state: _state),

                // view questions
                ProfileViewQuestionWidget(state: _state),
              ],
            ),
          ),
        ),
        // profile action toolbar
        if (_state.isActionToolbarAllowed)
          ProfileActionToolbarWidget(state: _state, isPrevPageMessages: _isPrevPageMessages),
      ],
    );
  }
}
