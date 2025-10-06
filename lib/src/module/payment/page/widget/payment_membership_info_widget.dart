import 'package:application/src/module/base/page/widget/modal_widget_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/service/localization_service.dart';
import '../../service/model/payment_membership_plan_model.dart';
import '../state/payment_membership_info_state.dart';
import '../style/payment_initial_page_style.dart';
import '../style/payment_membership_info_widget_style.dart';
import 'payment_initial_skeleton_widget.dart';

class PaymentMembershipInfoWidget extends StatefulWidget with ModalWidgetMixin {
  final int membershipId;
  final PaymentMembershipInfoDisplayMode displayMode;
  final String? membershipTitle;

  const PaymentMembershipInfoWidget({
    required this.membershipId,
    required this.displayMode,
    this.membershipTitle,
  });

  @override
  _PaymentMembershipInfoWidgetState createState() =>
      _PaymentMembershipInfoWidgetState();
}

class _PaymentMembershipInfoWidgetState
    extends State<PaymentMembershipInfoWidget> {
  late final PaymentMembershipInfoState _state;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<PaymentMembershipInfoState>();
    _state.init(membershipId: widget.membershipId);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header: widget.displayMode == PaymentMembershipInfoDisplayMode.info
            ? LocalizationService.of(context).t('your_membership')
            : widget.membershipTitle,
        scrollable: true,
        body: _state.isMembershipInfoLoaded
            ? _buildMembershipInfo()
            : PaymentInitialSkeletonWidget(),
        backgroundColor: !_state.isMembershipInfoLoaded
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  /// Build membership info view.
  Widget _buildMembershipInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Expiration date, displayed only in the membership info mode
        if (widget.displayMode == PaymentMembershipInfoDisplayMode.info)
          paymentMembershipInfoWidgetExpiringInfoWrapperContainer(
            _state.membership,
            LocalizationService.of(context).t('expires'),
            context,
          ),

        // Membership plans list, displayed only in the purchase mode
        if (widget.displayMode == PaymentMembershipInfoDisplayMode.purchase)
          ..._buildPlansList(),

        // Action list
        paymentInitialActionListWraperContainer(_buildActionList()),
      ],
    );
  }

  /// Build membership level actions list.
  List<Widget> _buildActionList() {
    return _state.membership.actions.fold<List<Widget>>(
      [],
      (prev, action) {
        final header = infoItemHeaderSectionContainer(context, action.label);

        final permissions = action.permissions.fold<List<Widget>>(
          [],
          (prev, permission) {
            final isLast = prev.length == action.permissions.length - 1;

            final permissionWidget = infoItemContainer(
              paymentInitialActionWrapperContainer(
                permission,
                context,
              ),
              context,
              backgroundColor: true,
              displayBorder: !isLast,
            );

            return [...prev, permissionWidget];
          },
        );

        return [...prev, header, ...permissions];
      },
    );
  }

  /// Build list of membership level plans available for purchase.
  Iterable<Widget> _buildPlansList() {
    return _state.membership.plans.map(
      (plan) => paymentMembershipInfoWidgetMembershipPlanContainer(
        context,
        // Trial plans have price set to 0.
        plan.price == 0
            ? LocalizationService.of(context).t('membership_plan_trial')
            : LocalizationService.of(context).t(
                'membership_plan_price',
                searchParams: [
                  'currency',
                  'price',
                ],
                replaceParams: [
                  _state.billingCurrency,
                  plan.price != null ? plan.price.toString() : '0',
                ],
              ),
        LocalizationService.of(context).t(
          'membership_plan_billing_period',
          searchParams: [
            'period',
            'periodUnits',
          ],
          replaceParams: [
            plan.period != null ? plan.period.toString() : '0',
            plan.periodUnits ?? '',
          ],
        ),
        isTrial: plan.price == 0,
        recurringText: plan.isRecurring
            ? LocalizationService.of(context).t('recurring')
            : '',
        onTapCallback: () => _returnMembershipPlan(plan),
      ),
    );
  }

  /// Return selected membership [plan] to the caller.
  void _returnMembershipPlan(PaymentMembershipPlanModel plan) {
    // Inform user that payments are disabled in demo mode if the page is opened
    // in the native app and the selected plan is not trial.
    if (!kIsWeb && plan.price != 0 && _state.isDemoModeActivated) {
      widget.showAlert(context, 'payment_disabled_in_demo_mode');

      return;
    }

    Navigator.pop(context, plan);
  }
}
