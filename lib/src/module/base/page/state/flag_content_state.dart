import 'package:mobx/mobx.dart';

import '../../service/flag_content_service.dart';
import '../widget/form/form_builder_widget.dart';

part 'flag_content_state.g.dart';

class FlagContentState = _FlagContentState with _$FlagContentState;

abstract class _FlagContentState with Store {
  final FlagContentService flagContentService;

  _FlagContentState({required this.flagContentService});

  void init(FormBuilderWidget formBuilder) {
    formBuilder.registerFormElements(flagContentService.getFormElements());
  }

  /// flag content
  void flagContent(
    int identityId,
    String entityType,
    String? reason,
  ) {
    flagContentService.flagContent(
      identityId,
      entityType,
      reason,
    );
  }
}
