import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../service/model/payment_membership_model.dart';
import '../../service/payment_service.dart';

part 'payment_membership_info_state.g.dart';

enum PaymentMembershipInfoDisplayMode {
  info,
  purchase,
}

class PaymentMembershipInfoState = _PaymentMembershipInfoState
    with _$PaymentMembershipInfoState;

abstract class _PaymentMembershipInfoState with Store {
  final RootState rootState;
  final PaymentService paymentService;

  /// Billing currency symbol.
  String get billingCurrency => rootState.getSiteSetting('billingCurrency', '');

  /// Is requested membership level info loaded.
  @observable
  bool isMembershipInfoLoaded = false;

  /// True if the demo mode is currently activated.
  bool get isDemoModeActivated => rootState.isDemoModeActivated;

  /// Extended membership level data.
  late PaymentMembershipModel membership;

  _PaymentMembershipInfoState({
    required this.rootState,
    required this.paymentService,
  });

  /// Load requested membership data, membership is identified by
  /// [membershipId].
  void init({required int membershipId}) async {
    membership = await paymentService.loadMembership(membershipId);
    isMembershipInfoLoaded = true;
  }
}
