import 'package:application/src/module/base/base_config.dart';
import 'package:application/src/module/base/page/state/root_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../style/payment_access_denied_widget_style.dart';
import 'payment_permission_widget_mixin.dart';

class CustomShowingPopupWidget extends StatelessWidget
    with ModalWidgetMixin, NavigationWidgetMixin, PaymentPermissionWidgetMixin {

  const CustomShowingPopupWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // a title
        paymentAccessDeniedWidgetTitleContainer(
          LocalizationService.of(context).t('popupmessages_notice_head'),
        ),
            // a description
            paymentAccessDeniedWidgetDescrContainer(
              LocalizationService.of(context).t(
                'popupmessages_notice_body',
              ),
            ),

            // dashboard
            paymentAccessDeniedWidgetBackButtonContainer(
                LocalizationService.of(context).t('go_to_dashboard'),
                    () => redirectToMainPage(context, unregisterDevice: false)
            ),
          ],
          // a back button
          // if (showLogoutButton)
          //   paymentAccessDeniedWidgetBackButtonContainer(
          //     LocalizationService.of(context).t('logout'),
          //         () => _logout(context)
          //   )

          // settingsPageButtonContainer(
          //   LocalizationService.of(context).t('logout'),
          //       () => widget.redirectToMainPage(
          //     context,
          //     cleanAuthCredentials: true,
          //   ),
          // ),
    );
  }

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  void _logout(BuildContext context) {
    GetIt.instance<RootState>().cleanAuthCredentials(
      unregisterDevice: true,
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      BASE_MAIN_URL,
          (r) => false,
    );
  }
}
