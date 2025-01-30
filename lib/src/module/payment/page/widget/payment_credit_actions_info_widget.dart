import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/service/localization_service.dart';
import '../../service/model/payment_credit_action_model.dart';
import '../state/payment_credit_actions_info_state.dart';
import '../style/payment_credit_actions_info_widget_style.dart';
import '../style/payment_initial_page_style.dart';
import 'payment_initial_skeleton_widget.dart';

class CreditActionsInfoWidget extends StatefulWidget {
  @override
  PaymentCreditActionsInfoWidgetState createState() =>
      PaymentCreditActionsInfoWidgetState();
}

class PaymentCreditActionsInfoWidgetState
    extends State<CreditActionsInfoWidget> {
  late final PaymentCreditActionsInfoState _state;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<PaymentCreditActionsInfoState>();
    _state.init();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => scaffoldContainer(
              context,
              header: LocalizationService.of(context).t(
                'cost_of_actions_page_title',
              ),
              body: _state.isCreditsInfoLoaded
                  ? _buildCreditActionsList()
                  : PaymentInitialSkeletonWidget(),
              scrollable: true,
              backgroundColor: !_state.isCreditsInfoLoaded
                  ? AppSettingsService.themeCommonScaffoldLightColor
                  : null,
            ));
  }

  /// Build credit actions info presentation list.
  Widget _buildCreditActionsList() {
    return paymentInitialActionListWraperContainer(
      <Widget>[
        // Receiving credits.
        ..._buildCreditActionInfoItemsList(
          _state.creditActionsInfo.earning,
          LocalizationService.of(context).t('receiving_credits'),
        ),

        // Losing credits.
        ..._buildCreditActionInfoItemsList(
          _state.creditActionsInfo.losing,
          LocalizationService.of(context).t('losing_credits'),
        ),
      ],
    );
  }

  /// Build a list of info items from the given [creditActions].
  Iterable<Widget> _buildCreditActionInfoItemsList(
    List<PaymentCreditActionModel> creditActions,
    String? firstItemHeader,
  ) {
    return creditActions.fold<List<Widget>>(
      [],
      (prev, action) {
        final isLastItem = (creditActions.length - prev.length) == 1;

        return [
          ...prev,
          infoItemContainer(
            paymentCreditActionsInfoWidgetActionWraperContainer(
              action.title,
              action.amount.toString(),
              context,
            ),
            context,
            header: prev.isEmpty ? firstItemHeader : null,
            displayBorder: !isLastItem,
            backgroundColor: true,
          ),
        ];
      },
    );
  }
}
