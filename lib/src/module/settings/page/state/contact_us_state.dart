import 'package:mobx/mobx.dart';

import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../service/contact_us_service.dart';

part 'contact_us_state.g.dart';

class ContactUsState = _ContactUsState with _$ContactUsState;

abstract class _ContactUsState with Store {
  final ContactUsService contactUsService;

  @observable
  bool isPageLoading = false;

  @observable
  bool isMessageSending = false;

  _ContactUsState({
    required this.contactUsService,
  });

  @action
  Future<void> initializeForm(FormBuilderWidget formBuilder) async {
    isPageLoading = true;

    formBuilder.registerFormElements(await contactUsService.getFormElements());

    isPageLoading = false;
  }

  @action
  Future<void> sendMessage(
    String? toEmail,
    String? fromEmail,
    String? subject,
    String? message,
  ) async {
    isMessageSending = true;

    await contactUsService.sendMessage({
      'to': toEmail,
      'from': fromEmail,
      'subject': subject,
      'message': message,
    });

    isMessageSending = false;
  }
}
