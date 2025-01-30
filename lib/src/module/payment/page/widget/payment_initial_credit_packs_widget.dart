import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../payment_config.dart';
import '../../service/model/payment_credit_pack_model.dart';
import '../../utility/payment_product_converter_utility.dart';
import '../state/payment_initial_credit_packs_state.dart';
import '../style/payment_initial_credit_packs_widget_style.dart';
import '../style/payment_initial_page_style.dart';
import 'payment_credit_actions_info_widget.dart';
import 'payment_initial_no_credit_packs_widget.dart';
import 'payment_initial_skeleton_widget.dart';

class PaymentInitialCreditPacksWidget extends StatefulWidget
    with FlushbarWidgetMixin, ModalWidgetMixin, NavigationWidgetMixin {
  @override
  _PaymentInitialCreditPacksWidgetState createState() =>
      _PaymentInitialCreditPacksWidgetState();
}

class _PaymentInitialCreditPacksWidgetState
    extends State<PaymentInitialCreditPacksWidget> {
  late final PaymentInitialCreditPacksState _state;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<PaymentInitialCreditPacksState>();
    _state.init();
  }

  @override
  void dispose() {
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => _state.isCreditPacksDataLoaded
          ? _buildCreditPacksView()
          : Expanded(
              child: PaymentInitialSkeletonWidget(),
            ),
    );
  }

  /// Build the credit packs view.
  Widget _buildCreditPacksView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Balance info.
            paymentInitialMembershipWidgetUserInfoWrapperContainer(
              LocalizationService.of(context).t('your_credits'),
              paymentInitialMembershipWidgetUserInfoContainer(
                _state.creditPacksData.balance.toString(),
                _showCreditActionsInfo,
                infoColor:
                    AppSettingsService.themeCommonPaymentInitialHighlightColor,
              ),
            ),

            // Credit packs list.
            if (_state.creditPacksData.packs.isEmpty)
              PaymentInitialNoCreditPacksWidget()
            else
              paymentInitialCreditPacksWidgetListWrapperContainer(
                _buildCreditPacksList().toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Convert credit packs list into presentation widgets.
  Iterable<Widget> _buildCreditPacksList() {
    return _state.creditPacksData.packs.map<Widget>(
      (pack) => paymentInitialPagePricedProductItemContainer(
        context,
        pack.credits.toString(),
        LocalizationService.of(context).t('credits'),
        LocalizationService.of(context).t(
          'credit_pack',
          searchParams: ['currency', 'price'],
          replaceParams: [
            _state.billingCurrency,
            pack.price.toString(),
          ],
        ),
        onTapCallback: () => _onCreditPackContainerTap(pack),
      ),
    );
  }

  /// Show credit actions list & cost modal if this information is available.
  void _showCreditActionsInfo() {
    if (_state.isNativePurchasePending) {
      return;
    }

    if (_state.creditPacksData.isInfoAvailable) {
      showPlatformDialog(
        context: context,
        builder: (_) => CreditActionsInfoWidget(),
      );

      return;
    }

    widget.showAlert(
      context,
      'credits_info_not_available_message',
      title: 'credits_info_not_available_title',
    );
  }

  void _onCreditPackContainerTap(PaymentCreditPackModel pack) {
    if (!kIsWeb && _state.isDemoModeActivated) {
      widget.showAlert(context, 'payment_disabled_in_demo_mode');

      return;
    }

    if (_state.isNativePurchasePending) {
      return;
    }

    kIsWeb ? _pushBillingGatewaysPage(pack) : _handleNativePurchase(pack);
  }

  /// Push billing gateways page for the given [creditPack] onto the
  /// navigation stack.
  void _pushBillingGatewaysPage(PaymentCreditPackModel creditPack) {
    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        PAYMENT_BILLING_GATEWAYS_URL,
        [
          'productId',
        ],
        [
          PaymentProductConverterUtility.urlifyProductId(creditPack.productId),
        ],
      ),
      arguments: {
        'product': creditPack,
      },
    );
  }

  /// Purchase [creditPack] from the native store.
  void _handleNativePurchase(PaymentCreditPackModel creditPack) async {
    _state.handleNativePurchase(creditPack);
  }
}
