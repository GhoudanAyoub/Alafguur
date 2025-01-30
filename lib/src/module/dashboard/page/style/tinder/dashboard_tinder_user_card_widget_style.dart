import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/user_avatar_widget.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../base/service/model/user_model.dart';

final dashboardTinderUserCardWidgetToolbarContainer = (
  Widget child,
) =>
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: child,
    );

final dashboardTinderUserCardWidgetPreviewContainer = (
  Widget child,
) =>
    Positioned.fill(
      child: child,
    );

final dashboardTinderUserCardWidgetFiltersContainer = (
  Function userCardClickCallbackSettings,
) =>
    Styled.widget(
      child: Icon(
        Icons.tune,
        size: 14,
        color: AppSettingsService.themeCommonIconLightColor,
      ).padding(horizontal: 2),
    )
        .padding(
          all: 8,
        )
        .decorated(
          color: AppSettingsService
              .themeCommonDashboardTinderUserCardWidgetFiltersBackgroundColor
              .withOpacity(0.5),
          border: Border.all(
            color: AppSettingsService
                .themeCommonDashboardTinderUseCardWidgetFiltersBorderColor
                .withOpacity(0.5),
          ),
          shape: BoxShape.circle,
        )
        .gestures(
          onTap: () => userCardClickCallbackSettings(),
        )
        .padding(
          top: 11,
        );

final dashboardTinderUserCardWidgetCardsContainer = (
  BuildContext context,
  Widget child,
) =>
    Positioned.fill(
      top: -MediaQuery.of(context).size.height * 0.03,
      bottom: 48,
      right: 0,
      child: child,
    );

final dashboardTinderUserCardWidgetSwipeTextContainer = (
  String message,
) =>
    Text(
      message.toUpperCase(),
    )
        .textColor(
          AppSettingsService
              .themeCommonDashboardTinderUserCardWidgetSwipeTextColor,
        )
        .fontSize(26)
        .padding(
          horizontal: 16,
          vertical: 4,
        )
        .decorated(
          border: Border.all(
            width: 3.2,
            color: AppSettingsService
                .themeCommonDashboardTinderUserCardWidgetSwipeBorderColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        );

final dashboardTinderUserCardWidgetCardContainer = (
  UserModel user,
  Function userCardClickCallback,
  BuildContext context, {
  String? distance,
  bool isCardMovingToLeft = false,
  bool isCardMovingToRight = false,
  int cardIndex = 0,
  int activeCardIndex = 0,
  bool isPreviewMode = false,
  bool isFiltersAllowed = false,
  Function? userCardClickCallbackSettings,
}) =>
    Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: [
        // a user card
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: UserAvatarWidget(
              isUseBigAvatar: true,
              avatarWidth: double.infinity,
              avatarHeight: double.infinity,
              avatar: user.avatar,
              usePendingAvatar: true,
            ).backgroundColor(
              AppSettingsService.themeCommonScaffoldDefaultColor,
            ),
          ),
        ),
        // a black overlay for text
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: Container().decorated(
              gradient: LinearGradient(
                colors: [
                  transparentColor(),
                  AppSettingsService.themeCommonHardcodedBlackColor
                      .withOpacity(0.56),
                ],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // display a match text
        if (cardIndex == activeCardIndex)
          Stack(
            children: [
              if (isCardMovingToLeft && !isRtlMode(context))
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Styled.widget().backgroundColor(
                      AppSettingsService
                          .themeCommonDashboardTinderUserCardWidgetSwipeLikeBackgroundColor
                          .withOpacity(0.2),
                    ),
                  ),
                ),
              if (isCardMovingToLeft && isRtlMode(context))
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Styled.widget().backgroundColor(
                      AppSettingsService
                          .themeCommonDashboardTinderUserCardWidgetSwipeDislikeBackgroundColor
                          .withOpacity(0.2),
                    ),
                  ),
                ),
              if (isCardMovingToRight && !isRtlMode(context))
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Styled.widget().backgroundColor(
                      Colors.green.withOpacity(0.2),
                    ),
                  ),
                ),
              if (isCardMovingToRight && isRtlMode(context))
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Styled.widget().backgroundColor(
                      Colors.red.withOpacity(0.2),
                    ),
                  ),
                ),
              if (isCardMovingToLeft && !isRtlMode(context))
                Positioned.directional(
                  top: 10,
                  end: 16,
                  textDirection: TextDirection.ltr,
                  child: dashboardTinderUserCardWidgetSwipeTextContainer(
                    LocalizationService.of(context).t('dislike'),
                  ),
                ),
              if (isCardMovingToRight && isRtlMode(context))
                Positioned.directional(
                  top: 10,
                  start: 16,
                  textDirection: TextDirection.ltr,
                  child: dashboardTinderUserCardWidgetSwipeTextContainer(
                    LocalizationService.of(context).t('dislike'),
                  ),
                ),
              if (isCardMovingToRight && !isRtlMode(context))
                Positioned.directional(
                  top: 10,
                  start: 16,
                  textDirection: TextDirection.ltr,
                  child: dashboardTinderUserCardWidgetSwipeTextContainer(
                    LocalizationService.of(context).t('like'),
                  ),
                ),
              if (isCardMovingToLeft && isRtlMode(context))
                Positioned.directional(
                  top: 10,
                  end: 16,
                  textDirection: TextDirection.ltr,
                  child: dashboardTinderUserCardWidgetSwipeTextContainer(
                    LocalizationService.of(context).t('like'),
                  ),
                ),
            ],
          ),

        // a user info
        Positioned(
          left: 32,
          right: 32,
          bottom: 16,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // a basic user info
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // a user name
                    Flexible(
                      child: Text(user.userName!)
                          .fontSize(20)
                          .textColor(
                            AppSettingsService.themeCommonHardcodedWhiteColor,
                          )
                          .textShadow(
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          )
                          .textAlignment(TextAlign.center),
                    ),
                    // a user age
                    if (user.age != null)
                      Text(', ' + user.age.toString()).fontSize(20).textColor(
                            AppSettingsService.themeCommonHardcodedWhiteColor,
                          ),
                    // a user online status
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

                // a user distance
                if (distance != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          distance,
                        )
                            .fontSize(14)
                            .textShadow(
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            )
                            .textColor(
                              AppSettingsService
                                  .themeCommonDashboardTinderUserCardWidgetDistanceColor,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (isFiltersAllowed)
          Positioned.directional(
            textDirection: TextDirection.ltr,
            bottom: 16,
            end: 16,
            child: dashboardTinderUserCardWidgetFiltersContainer(
              () => userCardClickCallbackSettings?.call(),
            ),
          )
      ],
    ).gestures(
      onTap: () => userCardClickCallback(),
    );
