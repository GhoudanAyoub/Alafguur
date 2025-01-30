import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/style/simple_html_page_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../../base/service/localization_service.dart';
import '../../base/service/model/user_model.dart';
import 'state/join_finalize_state.dart';
import 'style/join_finalize_page_style.dart';

final serviceLocator = GetIt.instance;

class JoinFinalizePage extends AbstractPage {
  const JoinFinalizePage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _JoinFinalizePageState createState() => _JoinFinalizePageState();
}

class _JoinFinalizePageState extends State<JoinFinalizePage> {
  late final JoinFinalizeState _state;
  late final FormBuilderWidget _formBuilderWidget;
  late final UserModel _joinInitialValues;

  static const _SKELETON_BARS_COUNT = 4;

  @override
  void initState() {
    super.initState();

    _joinInitialValues = UserModel.fromJson(widget.widgetParams!);

    _state = serviceLocator.get<JoinFinalizeState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.init(_joinInitialValues.sex, _formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t('join_page_header'),
        showHeaderBackButton: !_state.isUserCreating,
        headerActions: !_state.isPageLoading
            ? [
                !_state.isUserCreating
                    ? appBarTextButtonContainer(
                        _finalize,
                        LocalizationService.of(context).t('done'),
                      )
                    : scaffoldHeaderActionLoading(),
              ]
            : null,
        body: _state.isPageLoading
            ? _joinFinalizeSkeleton()
            : _joinFinalizePage(),
        scrollable: true,
        disableContent: _state.isUserCreating,
        backgroundColor: _state.isPageLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  Widget _joinFinalizeSkeleton() {
    return ListSkeletonWidget(
      barsCount: _SKELETON_BARS_COUNT,
    );
  }

  Widget _joinFinalizePage() {
    return formBasedPageContainer(
      Column(
        children: [
          // join form elements
          formBasedPageFormContainer(
            _formBuilderWidget,
            paddingBottom: 0,
          ),
          // tos switcher
          if (_state.isTosActive()) ...[
            infoItemHeaderSectionContainer(context, 'tos_section'),
            joinFinalizePageTosContainer(
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppSettingsService.themeCommonAccentColor,
                    ),
                    onPressed: () => _showTosPopup(),
                    child: joinFinalizePageTosLinkTextContainer(
                      LocalizationService.of(context).t('tos_agree_button'),
                    ),
                  ),
                  PlatformSwitch(
                    cupertino: (_, __) => CupertinoSwitchData(
                      activeColor: AppSettingsService.themeCommonAccentColor,
                    ),
                    onChanged: (bool value) {
                      _state.tosValue = value;
                    },
                    value: _state.tosValue,
                  ),
                ],
              ),
              context,
            ),
          ],
        ],
      ),
      paddingBottom: 50,
    );
  }

  _finalize() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    // validate both the TOS and form
    if (!isFormValid || !_state.isTosValid()) {
      // tos is not selected
      if (isFormValid && !_state.isTosValid()) {
        widget.showMessage('tos_agree_input_error', context);

        return;
      }

      widget.showMessage('form_general_error', context);

      return;
    }

    await _state.createUser(
      _joinInitialValues,
      _formBuilderWidget.getFormElementsList(),
    );

    // redirect to the dashboard
    widget.logJoin();
    widget.redirectToMainPage(context);
  }

  void _showTosPopup() {
    showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t('tos_page_header'),
        body: joinFinalizePageTosPopupTextContainer(
          Html(
            data: LocalizationService.of(context).t(
              'tos_page_content',
              removeHtmlTags: false,
            ),
            style: simpleHtmlPageHtmlStyleContainer,
          ),
        ),
        showHeaderBackButton: false,
        scrollable: true,
        headerActions: [
          appBarTextButtonContainer(
            () => Navigator.pop(context),
            LocalizationService.of(context).t('close'),
          )
        ],
      ),
    );
  }
}
