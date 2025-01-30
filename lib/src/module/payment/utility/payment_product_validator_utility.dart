import '../service/model/payment_credit_pack_model.dart';
import '../service/model/payment_membership_plan_model.dart';

class PaymentProductValidatorUtility {
  static bool validateProductType(dynamic product) {
    return product is PaymentMembershipPlanModel ||
        product is PaymentCreditPackModel;
  }
}
