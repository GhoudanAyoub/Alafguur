import 'package:application/src/module/payment/page/taaj_custom_page.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/route_guard/pwa_only_guard.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../base/base_config.dart';
import '../base/page/state/root_state.dart';
import 'page/payment_billing_gateways_page.dart';
import 'page/payment_initial_page.dart';
import 'page/state/payment_billing_gateways_state.dart';
import 'page/state/payment_credit_actions_info_state.dart';
import 'page/state/payment_in_app_purchase_state.dart';
import 'page/state/payment_initial_credit_packs_state.dart';
import 'page/state/payment_initial_membership_state.dart';
import 'page/state/payment_membership_info_state.dart';
import 'page/state/payment_state.dart';
import 'route_guard/product_type_guard.dart';
import 'service/payment_service.dart';

final serviceLocator = GetIt.instance;

const PAYMENT_BILLING_GATEWAYS_URL = '/upgrades/:productId/billing-gateways';
const PAYMENT_PROCESSING_URL = '/upgrades/order/:orderId';
const TAAJ_CUSTOM_URL = '/taaj';

// Paypal state flags.
const STRIPE_STATUS_PARAMETER_FLAG = 'stripe_payment_status';
const PAYPAL_PAYMENT_COMPLETED_FLAG = 'paypal_payment_completed';

List<RouteModel> getPaymentRoutes() {
  return [
    RouteModel(
      path: BASE_PAYMENT_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          PaymentInitialPage(routeParams, widgetParams),
    ),
    RouteModel(
      path: PAYMENT_BILLING_GATEWAYS_URL,
      visibility: RouteVisibility.member,
      guards: [
        productTypeGuard('product'),
        pwaOnlyGuard(),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          PaymentBillingGatewaysPage(routeParams, widgetParams),
    ),
    RouteModel(
      path: TAAJ_CUSTOM_URL,
      visibility: RouteVisibility.member,
      pageFactory: (Map<String, dynamic> routeParams, Map<String, dynamic> widgetParams) {
        return TaajCustomPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [],
    )
  ];
}

void initPaymentServiceLocator() {
  // dependency
  serviceLocator.registerLazySingleton(
    () => InAppPurchase.instance,
  );

  // service
  serviceLocator.registerLazySingleton(
    () => PaymentService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerLazySingleton(
    () => PaymentState(
      rootState: serviceLocator.get<RootState>(),
      inAppPurchaseState: serviceLocator.get<PaymentInAppPurchaseState>(),
      paymentService: serviceLocator.get<PaymentService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => PaymentInitialMembershipState(
      paymentState: serviceLocator.get<PaymentState>(),
      paymentService: serviceLocator.get<PaymentService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => PaymentInitialCreditPacksState(
      rootState: serviceLocator.get<RootState>(),
      paymentState: serviceLocator.get<PaymentState>(),
      paymentService: serviceLocator.get<PaymentService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => PaymentInAppPurchaseState(
      rootState: serviceLocator.get<RootState>(),
      paymentService: serviceLocator.get<PaymentService>(),
      inAppPurchase: serviceLocator.get<InAppPurchase>(),
    ),
  );

  serviceLocator.registerFactory(
    () => PaymentMembershipInfoState(
      rootState: serviceLocator.get<RootState>(),
      paymentService: serviceLocator.get<PaymentService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => PaymentCreditActionsInfoState(
      paymentService: serviceLocator.get<PaymentService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => PaymentBillingGatewaysState(
      rootState: serviceLocator.get<RootState>(),
      paymentService: serviceLocator.get<PaymentService>(),
      httpService: serviceLocator.get<HttpService>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
    ),
  );
}
