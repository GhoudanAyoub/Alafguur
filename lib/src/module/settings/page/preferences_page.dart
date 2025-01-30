import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/preferences_state.dart';
import 'widget/settings_page_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

/// Generic page to display and set user preferences.
class PreferencesPage extends AbstractPage {
  /// Preferences section name.
  final String section;

  /// Preferences page title.
  final String title;

  PreferencesPage({
    Key? key,
    Map<String, dynamic> routeParams = const {},
    Map<String, dynamic> widgetParams = const {},
    required this.section,
    required this.title,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final PreferencesState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<PreferencesState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.initializeSection(widget.section, _formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          header: LocalizationService.of(context).t(widget.title),
          headerActions: _state.isSectionInitialized
              ? [
                  _state.isSaveRequestPending
                      ? scaffoldHeaderActionLoading()
                      : appBarTextButtonContainer(
                          _save,
                          LocalizationService.of(context).t('done'),
                        ),
                ]
              : null,
          body: _state.isSectionInitialized
              ? Column(
                  children: [
                    formBasedPageContainer(
                      formBasedPageFormContainer(
                        _formBuilderWidget,
                        paddingBottom: 0,
                      ),
                    ),
                  ],
                )
              : SettingsPageSkeletonWidget(),
        );
      },
    );
  }

  /// Save preferences.
  void _save() {
    _state.save(_formBuilderWidget).whenComplete(
          () => widget.showMessage('preferences_saved', context),
        );
  }
}
