import 'package:get_it/get_it.dart';

import '../../../app/service/model/route_model.dart';
import '../../base/page/widget/error/not_found_widget.dart';
import '../service/model/payment_credit_pack_model.dart';
import '../service/model/payment_membership_plan_model.dart';
import '../utility/payment_product_validator_utility.dart';

/// Validates product in the widget params of the requested widget.
///
/// The product instance is retrieved using the [productMapKey]. If [allowNull]
/// is false and the widget params object is not a map or it doesn't contain
/// [productMapKey], the guard is considered failed and a [NotFoundWidget]
/// instance is returned.
///
/// The retrieved instance type should be either [PaymentMembershipPlanModel]
/// or [PaymentCreditPackModel] in order for the guard to pass. If the product
/// is null and [allowNull] is true, the guard will pass too. Otherwise, the
/// guard will fail and an instance of [NotFoundWidget] will be returned.
RouteGuard productTypeGuard(
  String productMapKey, {
  bool allowNull = true,
}) {
  return (
    RouteModel routeModel,
    Map routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    if (!(widgetParams is Map)) {
      return !allowNull ? NotFoundWidget() : null;
    }

    final product = widgetParams[productMapKey];

    if (product == null) {
      return !allowNull ? NotFoundWidget() : null;
    }

    return !PaymentProductValidatorUtility.validateProductType(product)
        ? NotFoundWidget()
        : null;
  };
}
