import 'package:flutter/widgets.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/service/localization_service.dart';
import '../style/payment_initial_page_style.dart';

class PaymentInitialNoCreditPacksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return paymentInitialEmptyWidgetWrapperContainer(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // No credit packs icon.
          blankBasedPageImageContainer(
            SkMobileFont.ic_no_credits,
            100,
            paddingBottom: 50,
          ),
          // No credit packs title.
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('no_credits'),
          ),
        ],
      ),
    );
  }
}
