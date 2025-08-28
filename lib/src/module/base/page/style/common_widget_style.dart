import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' as intl;
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../service/localization_service.dart';
import '../../service/model/user_model.dart';
import '../widget/loading_spinner_widget.dart';
import '../widget/user_avatar_widget.dart';

/// check if the rtl mode is active
bool isRtlMode(BuildContext context) {
  return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
}

/// transparent color
Color transparentColor() => Color(0x00000000);

Widget scaffoldHeaderActionLoading() {
  return LoadingSpinnerWidget(
    width: 50,
    height: 50,
  );
}

/// a scaffold container
Widget scaffoldContainer(
  BuildContext context, {
  required Widget body,
  String? header,
  List<Widget>? headerActions,
  bool showHeaderBackButton = true,
  Key? key,
  bool scrollable = false,
  bool disableContent = false,
  Color? backgroundColor,
  bool useSafeArea = true,
  Function? headerClickCallback,
  Function? backButtonCallback,
}) {
  PlatformAppBar? appBarWidget = header != null || headerActions != null
      ? PlatformAppBar(
          automaticallyImplyLeading: showHeaderBackButton,
          trailingActions: headerActions != null ? headerActions : [],
          material: (_, __) => MaterialAppBarData(
            title: header != null
                ? Text(header)
                    .fontWeight(FontWeight.bold)
                    .fontSize(17)
                    .gestures(
                      onTap: () => headerClickCallback?.call(),
                    )
                : null,
            elevation: 0,
            bottom: PreferredSize(
                child: Container(
                  color: AppSettingsService.themeCommonAppBarBorderColor,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(4.0)),
            iconTheme: IconThemeData(
              color: AppSettingsService.isDarkMode
                  ? AppSettingsService.themeCommonTextColor
                  : null,
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            title: header != null
                ? Text(header)
                    .textColor(AppSettingsService.themeCommonTextColor)
                    .fontSize(17)
                    .gestures(
                      onTap: () => headerClickCallback?.call(),
                    )
                : null,
            padding: EdgeInsetsDirectional.only(
              end: 8,
            ),
            border: Border(
              bottom: BorderSide(
                color: AppSettingsService.themeCommonAppBarBorderColor,
              ),
            ),
          ),
        )
      : null;
  Widget content = AbsorbPointer(
    absorbing: disableContent,
    child: disableContent
        ? Opacity(
            opacity: 0.5,
            child: body,
          )
        : body,
  );
  if (scrollable) {
    content = SingleChildScrollView(child: content);
  }
  final Widget contentWrapper = useSafeArea
      ? SafeArea(
          child: content,
          bottom: false,
        )
      : content;
  return WillPopScope(
    onWillPop: () async {
      if (backButtonCallback != null) {
        backButtonCallback();
      }

      return !disableContent;
    },
    child: PlatformScaffold(
      widgetKey: key,
      appBar: appBarWidget,
      body: contentWrapper,
      backgroundColor: backgroundColor,
    ).gestures(
      onTap: () {
        // automatically hide the keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
    ),
  );
}

/// an appbar text button
final appBarTextButtonContainer = (
  Function clickCallback,
  String label, {
  double paddingHorizontalMaterial = 16,
}) =>
    TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppSettingsService.themeCommonAccentColor,
        padding: EdgeInsets.symmetric(
          horizontal: 0,
        ),
      ),
      onPressed: () => clickCallback(),
      child: PlatformWidget(
        material: (_, __) => PlatformText(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ).padding(
          horizontal: paddingHorizontalMaterial,
        ),
        cupertino: (_, __) => PlatformText(
          label,
          style: TextStyle(
            fontSize: 17,
            wordSpacing: 0,
          ),
        ),
      ),
    );

/// an appbar loader button
final appBarLoaderButtonContainer = (
  String label, {
  double paddingHorizontalMaterial = 16,
}) =>
    Row(
      children: [
        LoadingSpinnerWidget(),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppSettingsService.themeCommonFormPlaceholderColor,
            padding: EdgeInsets.symmetric(
              horizontal: 0,
            ),
          ),
          onPressed: () => {},
          child: PlatformWidget(
            material: (_, __) => PlatformText(
              label,
              style: TextStyle(
                fontSize: 16,
              ),
            ).padding(
              horizontal: paddingHorizontalMaterial,
            ),
            cupertino: (_, __) => PlatformText(
              label,
              style: TextStyle(
                fontSize: 17,
                wordSpacing: 0,
              ),
            ),
          ),
        )
      ],
    );

/// a form error icon
Widget getFormErrorIcon({
  double size = 25,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppSettingsService.themeCommonDangerousColor,
      shape: BoxShape.circle,
      boxShadow: null,
    ),
    child: Icon(
      SkMobileFont.help,
      color: AppSettingsService.themeCommonIconLightColor,
      size: size / 1.5,
    ),
    margin: EdgeInsets.symmetric(horizontal: 5),
  );
}

/// blank based pages container
final Column Function(BuildContext, Widget, {Function backToStarterCallback})
    blankBasedPageContainer = (
  BuildContext context,
  Widget body, {
  Function? backToStarterCallback,
}) =>
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: body,
              ).alignment(Alignment.center),
            ),
            if (backToStarterCallback != null)
              Styled.widget(
                child: TextButton.icon(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 19,
                    color: AppSettingsService.themeCommonFormPlaceholderColor,
                  ),
                  label: Text(
                    LocalizationService.of(context).t(
                      'back_to_starter_page_button',
                    ),
                  )
                      .fontSize(
                        18,
                      )
                      .textColor(
                        AppSettingsService.themeCommonFormPlaceholderColor,
                      ),
                  onPressed: () => backToStarterCallback(),
                ),
              )
                  .padding(all: 10)
                  .backgroundColor(
                      AppSettingsService.themeCommonScaffoldDefaultColor)
                  .width(double.infinity),
          ],
        );

final blankBasedPageContentWrapperContainer = (
  Widget child, {
  Color backgroundColor = const Color(0x00000000),
}) =>
    child
        .backgroundColor(
          backgroundColor,
        )
        .alignment(Alignment.center);

final blankBasedPageImageContainer = (
  IconData? icon,
  double? sizeIcon, {
  Color? colorIcon,
  double paddingTop = 0,
  double paddingBottom = 16,
}) =>
    Icon(
      icon,
      color: colorIcon != null
          ? colorIcon
          : AppSettingsService.themeCommonSystemIconColor,
      size: sizeIcon,
    ).padding(
      top: paddingTop,
      bottom: paddingBottom,
    );

final blankBasedPageTitleContainer = (
  String? message, {
  Function? clickCallback,
}) =>
    Text(
      message!,
      textAlign: TextAlign.center,
    )
        .textColor(AppSettingsService.themeCommonBlankTitleColor)
        .fontSize(20)
        .padding(
          bottom: 16,
          horizontal: 16,
        )
        .gestures(
          onTap: () => clickCallback?.call(),
        );

final blankBasedPageDescrContainer = (
  String? message,
) =>
    Text(
      message!,
      textAlign: TextAlign.center,
    )
        .textColor(AppSettingsService.themeCommonBlankDescrColor)
        .fontSize(18)
        .padding(
          bottom: 40,
          horizontal: 16,
        );

final blankBasedPageButtonContainer = (
  BuildContext context,
  Function clickCallback,
  String label, {
  double paddingTop = 0,
}) =>
    Styled.widget(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppSettingsService.themeCommonAccentColor,
          minimumSize: Size(200, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
        ),
        child: Text(
          label,
        ).fontSize(18),
        onPressed: () => clickCallback(),
      )
          .height(
            48,
          )
          .padding(
            horizontal: 16,
            top: paddingTop,
          ),
    );

final blankBasedPageTextButtonContainer = (
  Function clickCallback,
  String? message,
) =>
    Styled.widget(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppSettingsService.themeCommonAccentColor,
        ),
        child: Text(
          message!,
          textAlign: TextAlign.center,
        )
            .fontSize(
              16,
            )
            .fontWeight(
              FontWeight.w400,
            ),
        onPressed: () => clickCallback(),
      ).padding(
        horizontal: 16,
      ),
    );

/// form based pages containers
final formBasedPageContainer = (
  Widget child, {
  double paddingTop = 0,
  double paddingBottom = 0,
}) =>
    Styled.widget(child: child)
        .backgroundColor(
          AppSettingsService.themeCommonScaffoldDefaultColor,
        )
        .padding(
          top: paddingTop,
          bottom: paddingBottom,
        );

final formBasedPageDescContainer = (
  String? message, {
  bool upperCase = false,
}) =>
    Text(
      upperCase ? message!.toUpperCase() : message!,
    )
        .textColor(AppSettingsService.themeCommonFormSectionColor)
        .fontSize(14)
        .padding(all: 10);

final formBasedPageFormContainer = (
  Widget? child, {
  double paddingBottom = 40,
}) =>
    Styled.widget(child: child)
        .backgroundColor(
          AppSettingsService.themeCommonScaffoldLightColor,
        )
        .padding(bottom: paddingBottom);

final userListItemRow = (
  BuildContext context,
  UserModel? user,
  Function cardClickCallback, {
  double avatarWidth = 70,
  double avatarHeight = 70,
  String? additionalInfo,
  bool isHighlighted = false,
}) =>
    Column(
      children: [
        Card(
          color: transparentColor(),
          margin: EdgeInsets.all(0),
          elevation: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // an avatar
              ClipOval(
                child: UserAvatarWidget(
                  isUseBigAvatar: false,
                  avatarHeight: avatarHeight,
                  avatarWidth: avatarWidth,
                  avatar: user!.avatar,
                ),
              ).padding(
                horizontal: 16,
                top: 8,
                bottom: 8,
              ),
              // a user info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // a user name
                    Text(user.userName!)
                        .textColor(AppSettingsService.themeCommonTextColor)
                        .fontSize(17)
                        .padding(
                          bottom: 3,
                        ),
                    // an additional info
                    if (additionalInfo != null)
                      Text(additionalInfo)
                          .textColor(
                            AppSettingsService.themeCommonInfoItemValueColor,
                          )
                          .fontSize(14),
                  ],
                ).paddingDirectional(
                  vertical: 8,
                  end: 8,
                ),
              ),
            ],
          ),
        )
            .backgroundColor(
              (isHighlighted
                  ? AppSettingsService.themeCommonUserListItemRowHighlightColor
                  : Colors.transparent),
            )
            .gestures(
              onTap: () => cardClickCallback(),
            ),
        Divider(
          indent: 96,
          height: 0,
        ),
      ],
    );

final userListSlideActionButtonContainer = (
  String? label,
  Function clickCallback,
  Color textColor,
  Color backgroundColor,
) =>
    SlidableAction(
      onPressed: (_) => clickCallback(),
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      icon: Icons.share,
      label: label ?? "",
    );

const double defaultUserCardWidth = 158;

/// a common user card
final Card Function({
  required UserModel user,
  String? distance,
  double cardWidth,
  double avatarHeight,
  Color borderCardColor,
}) userCardContainer = ({
  required UserModel user,
  String? distance,
  double cardWidth = defaultUserCardWidth,
  double avatarHeight = 140,
  Color? borderCardColor,
}) =>
    Card(
      color: AppSettingsService.themeCommonScaffoldLightColor,
      elevation: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: borderCardColor ?? transparentColor(),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        // width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // a user avatar
            Expanded(
              child: UserAvatarWidget(
                isUseBigAvatar: false,
                avatarHeight: avatarHeight,
                avatar: user.avatar,
              ),
            ),
            // a user info
            Container(
              alignment: Alignment.centerLeft,
              constraints: BoxConstraints(minHeight: 58),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 4,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          child: Text(
                            user.userName!,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                          )
                              .textColor(
                                  AppSettingsService.themeCommonTextColor)
                              .fontSize(16),
                        ),
                      ),
                      if (user.age != null)
                        Text(', ' + user.age.toString())
                            .textColor(AppSettingsService.themeCommonTextColor)
                            .fontSize(16),
                      if (user.isOnline!)
                        Icon(
                          Icons.fiber_manual_record,
                          color:
                              AppSettingsService.themeCommonUserCardOnlineColor,
                          size: 14,
                        ).padding(
                          top: 3,
                          horizontal: 3,
                        ),
                    ],
                  ),
                  // a user's location
                  if (distance != null)
                    Text(
                      distance,
                      style: TextStyle(
                        color:
                            AppSettingsService.themeCommonUserCardDistanceColor,
                      ),
                    ).fontSize(14).padding(top: 3),
                ],
              ),
            ).backgroundColor(
              AppSettingsService.isDarkMode
                  ? AppSettingsService.themeCommonScaffoldDefaultColor
                  : AppSettingsService.themeCommonScaffoldLightColor,
            ),
          ],
        ),
      ),
    );

/// preview photo modal window
final previewPhotosClosePageContainer = (
  Function clickCallback,
) =>
    PlatformIconButton(
      onPressed: () => clickCallback(),
      materialIcon: Icon(
        Icons.close,
        color: AppSettingsService.themeCommonPreviewPhotosCloseIconColor,
      ),
      cupertinoIcon: Icon(
        CupertinoIcons.clear,
        color: AppSettingsService.themeCommonPreviewPhotosCloseIconColor,
        size: 28,
      ),
    );

final previewPhotosFlagPhotoContainer = (
  Function clickCallback,
) =>
    PlatformIconButton(
      onPressed: () => clickCallback(),
      materialIcon: Icon(
        Icons.flag,
        color: AppSettingsService.themeCommonPreviewPhotosCloseIconColor,
      ),
      cupertinoIcon: Icon(
        CupertinoIcons.flag_fill,
        color: AppSettingsService.themeCommonPreviewPhotosCloseIconColor,
        size: 28,
      ),
    );

final previewPhotosPageContainer = (
  Widget child,
) =>
    Styled.widget(child: child).backgroundColor(
      AppSettingsService.themeCommonPreviewPhotosBackgroundColor,
    );

/// info item with/without header section
Widget infoItemContainer(
  Widget child,
  BuildContext context, {
  String? header,
  bool displayBorder = true,
  bool backgroundColor = false,
  Function? clickCallback,
  double innerPaddingVertical = 12,
}) {
  bool isRtlModeActive = isRtlMode(context);
  return Container(
    // wrapped in Container for gestures
    child: Column(
      children: [
        // header section
        if (header != null) infoItemHeaderSectionContainer(context, header),
        // body of info
        Styled.widget(
          child: child,
        )
            .padding(
              vertical: innerPaddingVertical,
            )
            .decorated(
              border: !displayBorder
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppSettingsService.themeCommonDividerColor,
                      ),
                    ),
            )
            .padding(
              left: !isRtlModeActive ? 16 : 0,
              right: isRtlModeActive ? 16 : 0,
            )
            .backgroundColor(
              backgroundColor
                  ? AppSettingsService.themeCommonScaffoldLightColor
                  : transparentColor(),
            ),
      ],
    ),
  ).gestures(onTap: clickCallback != null ? () => clickCallback() : null);
}

final infoItemLabelContainer = (
  String? message,
) =>
    Text(message!)
        .fontSize(17)
        .textColor(AppSettingsService.themeCommonInfoItemLabelColor)
        .padding(
          bottom: 4,
        );

final infoItemValueContainer = (
  String? message,
) =>
    Text(message!)
        .fontSize(14)
        .textColor(AppSettingsService.themeCommonInfoItemValueColor);

/// info header section
final infoItemHeaderSectionContainer = (
  BuildContext context,
  String? header,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          LocalizationService.of(context).t(header!).toUpperCase(),
        )
            .textColor(
              AppSettingsService.themeCommonFormSectionColor,
            )
            .fontSize(13)
      ],
    )
        .padding(
          top: 16,
          left: 16,
          bottom: 10,
          right: 16,
        )
        .backgroundColor(AppSettingsService.themeCommonScaffoldDefaultColor);

/// compatibility bar
final profileCompatibilityBarSectionContainer = (
  BuildContext context,
  String message,
  double percentage,
) =>
    ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 * percentage / 100,
            height: 20,
          )
              .decorated(
                color: AppSettingsService
                    .themeCustomProfileCompatibilityBarMainBackgroundColor,
              )
              .alignment(!isRtlMode(context)
                  ? Alignment.centerLeft
                  : Alignment.centerRight),
          Text(
            message,
          )
              .textColor(
                AppSettingsService.themeCommonHardcodedWhiteColor,
              )
              .fontSize(13)
              .alignment(
                Alignment.center,
              ),
        ],
      )
          .width(
            MediaQuery.of(context).size.width / 2,
          )
          .backgroundColor(
            AppSettingsService
                .themeCommonProfileCompatibilityBarBackgroundColor,
          ),
    ).padding(horizontal: 16);
