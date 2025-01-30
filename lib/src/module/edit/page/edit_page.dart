import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/edit_state.dart';
import 'widget/edit_photo_widget.dart';
import 'widget/edit_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class EditPage extends AbstractPage {
  const EditPage({Key? key, required routeParams, required widgetParams})
      : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditPage> {
  late final EditState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<EditState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.init(_formBuilderWidget);
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
        header: LocalizationService.of(context).t('edit_user_page_header'),
        showHeaderBackButton: !_state.isUserUpdating,
        headerActions: !_state.isPageLoading
            ? [
                !_state.isUserUpdating
                    ? appBarTextButtonContainer(
                        _save,
                        LocalizationService.of(context).t('done'),
                      )
                    : scaffoldHeaderActionLoading(),
              ]
            : null,
        body: _state.isPageLoading ? EditSkeletonWidget() : _editPage(),
        scrollable: true,
        disableContent: _state.isUserUpdating,
        backgroundColor: _state.isPageLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  Widget _editPage() {
    return formBasedPageContainer(
      Column(
        children: [
          // photos
          EditPhotoWidget(isPreviewMode: true),

          // edit form elements
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
    );
  }

  /// edit the current user's data
  _save() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    // validate form
    if (!isFormValid || !_state.isAvatarValid()) {
      // avatar is not uploaded
      if (!_state.isAvatarValid()) {
        widget.showMessage('avatar_input_error', context);

        return;
      }

      widget.showMessage('form_general_error', context);

      return;
    }

    await _state.editUser(
      _formBuilderWidget.getFormElementsList(),
    );

    widget.showMessage('profile_updated', context);
  }
}
