import 'package:mobx/mobx.dart';

import '../../service/model/payment_credit_actions_info_model.dart';
import '../../service/payment_service.dart';

part 'payment_credit_actions_info_state.g.dart';

class PaymentCreditActionsInfoState = _PaymentCreditActionsInfoState
    with _$PaymentCreditActionsInfoState;

abstract class _PaymentCreditActionsInfoState with Store {
  final PaymentService paymentService;

  @observable
  bool isCreditsInfoLoaded = false;

  /// Each available credit action's title and price in credits.
  late PaymentCreditActionsInfoModel creditActionsInfo;

  _PaymentCreditActionsInfoState({
    required this.paymentService,
  });

  /// Initialize credit actions information state.
  ///
  /// Load credit actions information from the backend.
  void init() async {
    creditActionsInfo = await paymentService.loadCreditsInfo();
    isCreditsInfoLoaded = true;
  }
}
