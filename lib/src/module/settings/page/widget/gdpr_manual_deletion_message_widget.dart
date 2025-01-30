import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/localization_service.dart';
import '../state/gdpr_settings_state.dart';

final serviceLocator = GetIt.instance;

class GdprManualDeletionMessageWidget extends StatefulWidget
    with FlushbarWidgetMixin {
  @override
  _GdprManualDeletionMessageWidgetState createState() =>
      _GdprManualDeletionMessageWidgetState();
}

class _GdprManualDeletionMessageWidgetState
    extends State<GdprManualDeletionMessageWidget> {
  late final GdprSettingsState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<GdprSettingsState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.initializeManualDeletionMessageForm(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      header: LocalizationService.of(context).t(
        'gdpr_third_party_popup_title',
      ),
      headerActions: [
        appBarTextButtonContainer(
          _dismiss,
          LocalizationService.of(context).t('cancel'),
          paddingHorizontalMaterial: 0,
        ),
        appBarTextButtonContainer(
          _sendMessageAndDismiss,
          LocalizationService.of(context).t('gdpr_third_party_send_btn'),
        ),
      ],
      body: formBasedPageContainer(
        Column(
          children: [
            infoItemHeaderSectionContainer(
              context,
              LocalizationService.of(context).t('gdpr_message_input'),
            ),
            Expanded(
              child: formBasedPageFormContainer(
                _formBuilderWidget,
                paddingBottom: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Send manual deletion message to the server administrator and dismiss the
  /// modal.
  void _sendMessageAndDismiss() async {
    if (!await _formBuilderWidget.isFormValid()) {
      widget.showMessage('form_general_error', context);
      return;
    }

    _state.sendManualDataDeletionMessage(
      _formBuilderWidget['manual_deletion_message']!.value,
    );

    widget.showMessage('gdpr_third_party_message_feedback', context);

    _dismiss();
  }

  /// Dismiss this modal.
  void _dismiss() {
    Navigator.pop(context);
  }
}
