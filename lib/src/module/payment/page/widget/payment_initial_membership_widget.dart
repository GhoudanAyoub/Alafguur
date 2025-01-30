import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../../settings/settings_config.dart';
import '../../payment_config.dart';
import '../../service/model/payment_membership_plan_model.dart';
import '../../utility/payment_product_converter_utility.dart';
import '../state/payment_initial_membership_state.dart';
import '../state/payment_membership_info_state.dart';
import '../style/payment_initial_membership_widget_style.dart';
import '../style/payment_initial_page_style.dart';
import 'payment_initial_no_memberships_widget.dart';
import 'payment_initial_skeleton_widget.dart';
import 'payment_membership_info_widget.dart';

class PaymentInitialMembershipWidget extends StatefulWidget
    with NavigationWidgetMixin, FlushbarWidgetMixin {
  const PaymentInitialMembershipWidget();

  @override
  _PaymentInitialMembershipWidgetState createState() =>
      _PaymentInitialMembershipWidgetState();
}

class _PaymentInitialMembershipWidgetState
    extends State<PaymentInitialMembershipWidget> {
  late final PaymentInitialMembershipState _state;

  /// Platform-dependent recurring payments information.
  String get recurringDescription {
    String key = '';

    if (kIsWeb) {
      key = 'app_mobile_recurring_information_description';
    } else if (Platform.isIOS) {
      key = 'app_ios_recurring_information_description';
    } else {
      key = 'app_android_recurring_information_description';
    }

    return LocalizationService.of(context).t(key, removeHtmlTags: false);
  }

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<PaymentInitialMembershipState>();
    _state.init();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => _state.membershipsLoaded
          ? _buildMembershipsView()
          : Expanded(
              child: PaymentInitialSkeletonWidget(),
            ),
    );
  }

  /// Build overall membership levels page view.
  Widget _buildMembershipsView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Your membership section.
            paymentInitialMembershipWidgetUserInfoWrapperContainer(
              LocalizationService.of(context).t('your_membership'),
              paymentInitialMembershipWidgetUserInfoContainer(
                _state.activeMembership!.title,
                _showMembershipInfoModal,
                infoColor: AppSettingsService.themeCommonAccentColor,
              ),
            ),

            // Memberships available for purchase.
            if (_state.memberships.isEmpty)
              PaymentInitialNoMembershipsWidget()
            else ...[
              paymentInitialMembershipWidgetMembershipsWrapperContainer(
                _buildMembershipsList().toList(),
              ),

              // Recurring payments information.
              infoItemHeaderSectionContainer(
                context,
                LocalizationService.of(context).t(
                  'app_recurring_information_label',
                ),
              ),
              Html(
                data: recurringDescription,
                style: paymentInitialMembershipWidgetHtmlStyleContainer,
              ),

              // Privacy policy and terms of use links.
              paymentInitialMembershipWidgetLinksWrapperContainer(
                [
                  // Privacy policy.
                  infoItemContainer(
                    paymentInitialPageInfoItemLinkContainer(
                      label: LocalizationService.of(context).t(
                        'app_settings_privacy_policy_label',
                      ),
                    ),
                    context,
                    innerPaddingVertical: 19,
                    backgroundColor: true,
                    clickCallback: _pushPrivacyPolicyPage,
                  ),

                  // Terms of use.
                  infoItemContainer(
                    paymentInitialPageInfoItemLinkContainer(
                      label: LocalizationService.of(context).t(
                        'app_settings_terms_of_use_label',
                      ),
                    ),
                    context,
                    innerPaddingVertical: 19,
                    backgroundColor: true,
                    displayBorder: false,
                    clickCallback: _pushTermsOfUsePage,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build list of membership levels available for purchase.
  Iterable<Widget> _buildMembershipsList() {
    return _state.memberships
        .where((membership) => membership.isPlansAvailable)
        .map<Widget>(
          (membership) => paymentInitialPageProductItemContainer(
            context,
            title: membership.title,
            onTapCallback: () => _showMembershipPurchaseModal(
              membership.id,
              membership.title,
            ),
          ),
        );
  }

  /// Show information about the current membership.
  void _showMembershipInfoModal() {
    showPlatformDialog(
      context: context,
      builder: (_) => PaymentMembershipInfoWidget(
        membershipId: _state.activeMembership!.id,
        displayMode: PaymentMembershipInfoDisplayMode.info,
      ),
    );
  }

  /// Show membership purchase modal.
  ///
  /// The membership to be purchased is identified by [membershipId].
  void _showMembershipPurchaseModal(
    int membershipId,
    String membershipTitle,
  ) async {
    final selectedPlan = await showPlatformDialog<PaymentMembershipPlanModel>(
      context: context,
      builder: (_) => PaymentMembershipInfoWidget(
        membershipId: membershipId,
        displayMode: PaymentMembershipInfoDisplayMode.purchase,
        membershipTitle: membershipTitle,
      ),
    );

    if (selectedPlan != null) {
      // Trial plans have price set to 0.
      if (selectedPlan.price == 0) {
        _handleTrialPlan(selectedPlan);
        return;
      }

      kIsWeb
          ? _pushBillingGatewaysPage(selectedPlan)
          : _handleNativePurchase(selectedPlan);
    }
  }

  /// Assign the provided trial membership [plan] to the active user, show
  /// error message if they already have a trial plan assigned.
  void _handleTrialPlan(PaymentMembershipPlanModel plan) async {
    if (_state.activeMembership!.isActiveAndTrial) {
      widget.showMessage('membership_trial_error', context);
      return;
    }

    try {
      await _state.grantTrialMembershipPlan(plan);

      widget.redirectToMainPage(context);

      widget.showMessage(
        'membership_trial_added',
        context,
        searchParams: [
          'amountDays',
        ],
        replaceParams: [
          plan.period.toString(),
        ],
      );
    } catch (_) {
      widget.redirectToMainPage(context);
      widget.showMessage('membership_trial_error', context);
    }
  }

  /// Push billing gateways page for the given [plan] onto the navigation stack.
  void _pushBillingGatewaysPage(PaymentMembershipPlanModel plan) {
    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        PAYMENT_BILLING_GATEWAYS_URL,
        [
          'productId',
        ],
        [
          PaymentProductConverterUtility.urlifyProductId(plan.productId),
        ],
      ),
      arguments: {
        'product': plan,
      },
    );
  }

  void _handleNativePurchase(PaymentMembershipPlanModel plan) async {
    await _state.handleNativePurchase(plan);
  }

  /// Push privacy policy page onto the navigation stack.
  void _pushPrivacyPolicyPage() {
    Navigator.pushNamed(context, SETTINGS_PRIVACY_POLICY_URL);
  }

  // Push terms of use page onto the navigation stack.
  void _pushTermsOfUsePage() {
    Navigator.pushNamed(context, SETTINGS_TERMS_OF_USE_URL);
  }
}
