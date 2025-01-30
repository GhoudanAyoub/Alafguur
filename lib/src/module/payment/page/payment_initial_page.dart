import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/style/segmented_control_style.dart';
import '../../base/service/localization_service.dart';
import 'state/payment_state.dart';
import 'widget/payment_initial_credit_packs_widget.dart';
import 'widget/payment_initial_membership_widget.dart';

class PaymentInitialPage extends AbstractPage {
  const PaymentInitialPage(
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
  ) : super(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _PaymentInitialPageState createState() => _PaymentInitialPageState();
}

class _PaymentInitialPageState extends State<PaymentInitialPage> {
  late final PaymentState _state;

  /// True if the memberships are selected as the current displayed product.
  bool get isMembershipsProductSelected =>
      _state.getActiveCurrentProductType() == ProductType.memberships;

  /// True if the credit packs are selected as the current displayed product.
  bool get isCreditPacksProductSelected =>
      _state.getActiveCurrentProductType() == ProductType.creditPacks;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<PaymentState>();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          header: LocalizationService.of(context).t('buy_upgrades_page_header'),
          headerActions:
              _state.isRequestPending || _state.isNativePurchasePending
                  ? [scaffoldHeaderActionLoading()]
                  : [],
          showHeaderBackButton:
              !(_state.isRequestPending || _state.isNativePurchasePending),
          disableContent: _state.isNativePurchasePending,
          body: Observer(
            builder: (_) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          // show segments when both membership and credits are activated
                          if (_isTabsVisible())
                            fullWidthSegmentedControl<ProductType>(
                              children: _getAvailableProductTabs(),
                              onValueChanged: _selectedProductChanged,
                              selectedValue:
                                  _state.getActiveCurrentProductType(),
                            ),

                          Expanded(
                            child: Column(
                              children: <Widget>[
                                // Selected product.
                                if (isMembershipsProductSelected)
                                  PaymentInitialMembershipWidget()
                                else if (isCreditPacksProductSelected)
                                  PaymentInitialCreditPacksWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Handle selected product category change.
  void _selectedProductChanged(ProductType productType) {
    _state.currentProductType = productType;
  }

  /// Get tabs for product categories available for purchase.
  Map<ProductType, Widget> _getAvailableProductTabs() {
    final Map<ProductType, Widget> tabs = {};

    tabs[ProductType.memberships] = defaultSegmentedControlItem(
      title: LocalizationService.of(context).t('memberships'),
    );

    tabs[ProductType.creditPacks] = defaultSegmentedControlItem(
      title: LocalizationService.of(context).t('credits'),
    );

    return tabs;
  }

  bool _isTabsVisible() {
    return _state.isMembershipsPluginActive && _state.isUserCreditsPluginActive;
  }
}
