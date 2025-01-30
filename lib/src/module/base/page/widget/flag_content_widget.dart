import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../state/flag_content_state.dart';
import '../style/common_widget_style.dart';
import 'flushbar_widget_mixin.dart';
import 'form/form_builder_widget.dart';

final serviceLocator = GetIt.instance;

class FlagContentWidget extends StatefulWidget with FlushbarWidgetMixin {
  FlagContentWidget({
    Key? key,
  }) : super(key: key);

  @override
  FlagContentWidgetState createState() => FlagContentWidgetState();
}

class FlagContentWidgetState extends State<FlagContentWidget> {
  late final FlagContentState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<FlagContentState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state.init(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return formBasedPageContainer(
      Column(
        children: [
          // form elements
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
      paddingTop: 20,
    );
  }

  /// validate the form and flag the content
  Future<void> flagContent(
    int identityId,
    String entityType, {
    Function? onFlaggedCallback,
  }) async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    _state.flagContent(
      identityId,
      entityType,
      _formBuilderWidget['reason']!.value[0],
    );

    Navigator.pop(context);

    if (onFlaggedCallback != null) {
      onFlaggedCallback();
    }
  }
}
