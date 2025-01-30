import 'package:application/src/module/base/page/state/root_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import '../join_config.dart';
import '../service/model/join_initial_avatar_model.dart';
import 'state/join_initial_state.dart';
import 'widget/join_initial_avatar_widget.dart';
import 'widget/join_initial_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class JoinInitialPage extends AbstractPage {
  const JoinInitialPage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _JoinInitialPageState createState() => _JoinInitialPageState();
}

class _JoinInitialPageState extends State<JoinInitialPage> {
  late final JoinInitialState _state;
  late final RootState _rootState;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<JoinInitialState>();
    _rootState = serviceLocator.get<RootState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.init(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t('join_page_header'),
        headerActions: !_state.isPageLoading && !_state.isAvatarUploading
            ? [
                appBarTextButtonContainer(
                  _nextStep,
                  LocalizationService.of(context).t('next'),
                ),
              ]
            : [
              appBarLoaderButtonContainer(
                  LocalizationService.of(context).t('next'),
               ),
            ],
        body: _state.isPageLoading
            ? JoinInitialSkeletonWidget()
            : _joinInitialPage(),
        scrollable: true,
        backgroundColor: _state.isPageLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  Widget _joinInitialPage() {
    return formBasedPageContainer(
      Column(
        children: [
          // avatar uploader
          if (!_state.isAvatarHidden())
            JoinInitialAvatarWidget(
              onAvatarUploadCallback: _avatarUploadedCallback(),
              onAvatarStartUploadingCallback: _avatarStartUploadingCallback(),
              onAvatarFinishUploadingCallback: _avatarFinishUploadingCallback(),
            ),
          // join form elements
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
    );
  }

  /// process uploaded avatar
  AvatarUploadedCallback _avatarUploadedCallback() {
    return (JoinInitialAvatarModel? avatar) {
      _state.setAvatar(avatar);
    };
  }

  AvatarStartUploadingCallback _avatarStartUploadingCallback() {
    return () {
      _state.setAvatar(null);
      _state.isAvatarUploading = true;
    };
  }

  AvatarFinishUploadingCallback _avatarFinishUploadingCallback() {
    return () {
      _state.isAvatarUploading = false;
    };
  }

  /// go to the next join step
  void _nextStep() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (_state.isAvatarRequired() && !_state.isAvatarUploaded()) {
      widget.showMessage('avatar_input_error', context);

      return;
    }

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    if (_rootState.isPluginAvailable('customemailverification')) {
      final formValues = _formBuilderWidget.getFormValues();
      final result = await _state.checkIfEmailValid(formValues['email']);

      if (!result.isEmailExists) {
        widget.showAlert(
          context,
          'kickbox_invalid_email',
          title: 'error_occurred',
        );

        return;
      }
    }

    Navigator.pushNamed(
      context,
      JOIN_FINALIZE_URL,
      arguments: {
        ..._formBuilderWidget.getFormValues(),
        'avatarKey': _state.getAvatar() != null ? _state.getAvatar()!.key : null
      },
    );
  }
}
