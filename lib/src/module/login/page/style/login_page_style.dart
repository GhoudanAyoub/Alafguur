
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/page/widget/image_loader_widget.dart';
import '../../../base/page/widget/loading_spinner_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';

final Widget Function({Widget child, String? customBackground})
    loginPageWrapperContainer = ({
  String? customBackground,
  Widget? child,
}) =>
        Styled.widget(
          child: child,
        ).decorated(
          image: DecorationImage(
            image: customBackground == null
                ? AssetImage('assets/image/login/index.jpg')
                : Image.network(customBackground).image,
            fit: BoxFit.cover,
          ),
        );

final loginPageLogoContainer = ({
  required int customLogoWidth,
  String? customLogo,
}) =>
    Styled.widget(
      child: customLogo == null
          ? Image.asset('assets/image/app/logo.png')
          : ImageLoaderWidget(
              imageUrl: customLogo,
              width: null,
              height: null,
              showPlaceholder: false,
            ),
    ).width(
      (customLogo != null ? customLogoWidth.toDouble() : 70),
    );

final Widget Function(
  BuildContext context, {
  Widget? child,
}) loginPageBodyContainer = (
  BuildContext context, {
  Widget? child,
}) =>
    Styled.widget(
      child: child,
    )
        .width(MediaQuery.of(context).size.width * 0.70)
        .padding(
          top: 10,
        )
        .alignment(Alignment.topCenter);

final loginPageLoginButtonContainer = (String? title, Function clickCallback,
        bool isLoading) =>
    Styled.widget(
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title!,
            )
                .fontSize(18)
                .fontWeight(FontWeight.w300)
                .textColor(
                  AppSettingsService.themeCommonLoginButtonColor,
                )
                .padding(horizontal: 8),
            if (isLoading)
              LoadingSpinnerWidget(
                radius: 9,
              ),
          ],
        ),
        onPressed: () => clickCallback(),
      )
          .decorated(
            color: AppSettingsService.themeCustomLoginFormButtonBackgroundColor,
            borderRadius: BorderRadius.circular(64.0),
          )
          .width(double.infinity)
          .height(48)
          .padding(
            top: 23,
            bottom: 32,
          ),
    );

final Widget Function({Widget child}) loginPageInlineButtonWrapperContainer = ({
  Widget? child,
}) =>
    Styled.widget(
      child: child,
    ).padding(
      top: 16,
    );

final loginPageInlineButtonContainer = (
  String? message, {
  double colorOpacity = 0.5,
}) =>
    Text(
      message!,
      style: TextStyle(
        color: AppSettingsService.themeCommonLoginInlineButtonColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );

final loginPageFirebaseLabelWrapperContainer = (
  String? title,
) =>
    Styled.widget(
      child: <Widget>[
        loginPageFirebaseLabelDividerContainer(),
        loginPageFirebaseLabelContainer(
          title!.toUpperCase(),
        ),
        loginPageFirebaseLabelDividerContainer(),
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    )
        .backgroundColor(
          transparentColor(),
        )
        .padding(
          horizontal: 32,
        );

final Widget Function({Widget child}) loginPageFirebaseLabelDividerContainer =
    ({
  Widget? child,
}) =>
        Styled.widget(
          child: Expanded(
            child: Divider(
              color: AppSettingsService.themeCommonLoginFirebaseDividerColor
                  .withOpacity(0.4),
            ),
          ),
        );

final loginPageFirebaseLabelContainer = (String message) => Text(
      message,
      style: TextStyle(
        color: AppSettingsService.themeCommonLoginFirebaseLabelColor,
        fontSize: 14,
      ),
    ).padding(horizontal: 6);

final Widget Function({Widget child}) loginPageFirebaseButtonsContainer = ({
  Widget? child,
}) =>
    Styled.widget(
      child: child,
    ).padding(
      horizontal: 4,
      top: 16,
      bottom: 16,
    );
final loginPageFirebaseButtonContainer = (
  Color backgroundColor,
  Color iconColor,
  IconData icon, {
  double iconPaddingBottom = 0,
}) =>
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      width: 47,
      height: 47,
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ).padding(
        bottom: iconPaddingBottom,
      ),
    );

final loginPageFirebaseButtonAppleContainer =
    () => loginPageFirebaseButtonContainer(
          AppSettingsService.themeCommonLoginFirebaseAppleIconBackgroundColor,
          AppSettingsService.themeCommonHardcodedBlackColor,
          SkMobileFont.apple,
          iconPaddingBottom: 4,
        );

final loginPageFirebaseButtonFbContainer = () =>
    loginPageFirebaseButtonContainer(
      AppSettingsService.themeCommonLoginFirebaseFacebookIconBackgroundColor,
      AppSettingsService.themeCommonIconLightColor,
      SkMobileFont.facebook,
    );

final loginPageFirebaseButtonGoogleContainer =
    () => loginPageFirebaseButtonContainer(
          AppSettingsService.themeCommonLoginFirebaseGoogleIconBackgroundColor,
          AppSettingsService.themeCommonIconLightColor,
          SkMobileFont.google,
        );

final loginPageFirebaseButtonTwitterContainer =
    () => loginPageFirebaseButtonContainer(
          AppSettingsService.themeCommonLoginFirebaseTwitterIconBackgroundColor,
          AppSettingsService.themeCommonIconLightColor,
          SkMobileFont.twitter,
        );

final loginPageFormTheme = () => FormTheme(
      valueColor: AppSettingsService.themeCommonLoginFormTextColor,
      placeHolderColor: AppSettingsService.themeCommonLoginFormPlaceholderColor,
      borderWidth: 0,
      borderColor: transparentColor(),
      textFieldTextAlign: TextAlign.center,
      textFieldPaddingEnd: 20,
    );

FormRendererCallback loginPageFormRenderer() {
  return (
    Map<String, Widget> presentationMap,
    Map<String, FormElementModel> elementMap,
    BuildContext context,
  ) {
    return <Widget>[
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              SkMobileFont.profile,
              color: AppSettingsService.themeCustomLoginFormInputIconColor,
              size: 17,
            ).paddingDirectional(end: 8),
            Expanded(
              child: presentationMap['username']!,
            ),
          ],
        ).padding(vertical: 6, horizontal: 12),
      )
          .decorated(
            color: AppSettingsService.themeCommonLoginFormInputBackgroundColor,
            borderRadius: BorderRadius.circular(4),
          )
          .padding(bottom: 20),
      Container(
        child: Row(
          children: [
            Icon(
              SkMobileFont.lock,
              color: AppSettingsService.themeCustomLoginFormInputIconColor,
              size: 19,
            ).paddingDirectional(end: 8),
            Expanded(
              child: presentationMap['password']!,
            ),
          ],
        ).padding(vertical: 6, horizontal: 12),
      ).decorated(
        color: AppSettingsService.themeCommonLoginFormInputBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
    ].toColumn();
  };
}
