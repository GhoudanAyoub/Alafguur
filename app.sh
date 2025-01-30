#!/usr/bin/env bash

# CHECK IF THE MAIN CONFIG FILES ARE EXIST
if [ ! -f config/theme.config ]; then
    echo "Copy theme config file"
    cp config/theme.config.tmpl config/theme.config
fi

if [ ! -f config/application.config ]; then
    echo "Copy config file"
    cp config/application.config.tmpl config/application.config
fi

# READ THE MAIN THEME CONFIG VALUES
. config/theme.config

# READ THE MAIN CONFIG VALUES
. config/application.config

# invocation format: ./app.sh command [argument]
# input command value
inputCommand=$1

# argument value (second command line argument)
inputCommandArg=$2

# list of supported commands
supportedCommands=(
    "prepare"
    "help"
    "build_web"
    "build_ios"
    "build_android"
    "build_android_appbundle"
    "build_dart"
    "clean"
)

# check if the given command is supported
if [[ ! "${supportedCommands[@]}" =~ "$inputCommand" ]]; then
    echo "Invalid command: $inputCommand. Supported commands are: ${supportedCommands[@]}"
    exit
fi

# THERE ARE SOME DIFFERENCES BETWEEN MAC AND LINUX BASED CONSOLE COMMANDS
sedCommand="sed -i" # the linux's command for replacing content in a file
if [[ "$OSTYPE" == darwin* ]]; then
    sedCommand="sed -i .backup"; # the mac's command for replacing content in a file
fi

# THE COMMAND WAS NOT RECEIVED
if [[ $inputCommand == "" ]]; then
    echo "No command specified. Supported commands are: ${supportedCommands[@]}"
    exit
fi

# SHOW THE HELP
if [[ $inputCommand == "help" ]]; then
  # do not delete the new lines and don't change the indentation, it will mess up the formatting.
  cat << HELP

Skadate mobile app project helper.

USAGE: app.sh [COMMAND]

Command reference:

  prepare                 -- install dependencies and initialize plugins. Running this command is
                             necessary in any freshly cloned skmobileapp repository.

  clean                   -- clean the project and delete generated files.

  help                    -- show this screen.

  build_web               -- build release web version of the application.

  build_web --zip         -- build and zip the web version of the application for easier deployment.

  build_ios               -- build iOS version of the application.

  build_android           -- build Android AppBundle.

  build_android --apk     -- build Android APKs split per ABI.

  build_dart              -- run Dart build_runner and (re)generate Dart code files.

HELP
fi

# BUILD THE WEB CONTEXT
if [[ $inputCommand == "build_web" ]]; then
    # build the PWA
    flutter build web --web-renderer canvaskit --release --no-sound-null-safety

    # remove dummy service worker if it exists
    [[ -f ./build/web/firebase-messaging-sw.js ]] && rm -f ./build/web/firebase-messaging-sw.js

    # merge service worker components
    filesToMerge=$(find ./build/web -type f -iname "*.sw-merge.js")
    mv ./build/web/flutter_service_worker.js ./build/web/firebase-messaging-sw.js

    for file in "${filesToMerge[@]}"; do
      cat $file >> ./build/web/firebase-messaging-sw.js
      rm $file
    done

    # gzip all code and asset files
    find ./build/web -type f \
                        \( \
                            -iname "*.html" \
                            -o -iname "*.js"   \
                            -o -iname "*.css"  \
                            -o -iname "*.svg"  \
                            -o -iname "*.xml"  \
                            -o -iname "*.map"  \
                            -o -iname "*.ttf"  \
                            -o -iname "*.otf"  \
                            -o -iname "*.json"  \
                        \) \
                        -exec sh -c 'gzip <{} >{}.gz' \;

    # Flutter build quirk workaround: copy image assets dir to its expected path
    cp -f -r ./build/web/assets/assets/image ./build/web/assets/

    # cp everything to the plugin's static directory
    cp -f -r ./build/web/* ./www/

    # remove gzipped files from the build folder
    rm -f $(find ./build/web -iname "*.gzip")

    if [[ $inputCommandArg == '--zip' ]]; then
        echo "Generating build archive..."

        # save the current directory
        oldPwd=$(pwd)

        # form absolute path to the build archive
        filename="$oldPwd/skmobile_web.zip"

        if [[ -f $filename ]]; then
            # if the build archive already exists, generate a random suffix and append it to the archive file name
            filenameSuffix=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 6)
            filename="$oldPwd/skmobile_web_$filenameSuffix.zip"
        fi

        # go to the www directory
        cd "$oldPwd/www"

        # zip every file there, use the "./.[^.]" construct to add files starting with "." but at the same time skip
        # the parent directory ".."
        zip -9r --quiet "$filename" ./* ./.*[^.]

        # go to the previous directory
        cd $oldPwd

        echo "Generated build archive: $filename"
    fi
fi

# BUILD THE IOS CONTEXT
if [[ $inputCommand == "build_ios" ]]; then
    flutter build ipa
fi

# BUILD THE ANDROID CONTEXT
if [[ $inputCommand == "build_android" ]]; then
    if [[ $inputCommandArg == "--apk" ]]; then
      echo "Building Android APKs"
      flutter build apk --release --split-per-abi
    else
      echo "Building Android AppBundle"
      flutter build appbundle --release
    fi
fi

# BUILD THE DART CODE
if [[ $inputCommand == "build_dart" ]]; then
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# GENERATE A SPLASH SCREEN, LAUNCH ICONS, PWA CONFIGS, ETC (PREPARE THE WORKING ENVIRONMENT)
if [[ $inputCommand == "prepare" ]]; then
    # run flutter pub get
    flutter pub get

    echo "Enable web platform"

    # enable flutter web platform
    flutter config --enable-web

    echo "Generate PWA files"

    # build the app config file
    cp config/platform/common/app_settings_service.dart.tmpl lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__build_name__|$NAME|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__bundle_name__|$BUNDLE_NAME|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__version__|$VERSION|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__version_build__|$VERSION_BUILD|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__debug_mode__|$DEBUG_MODE|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__api_protocol__|$API_PROTOCOL|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__api_domain__|$API_DOMAIN|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__api_uri__|$API_URI|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__app_name___|$NAME|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__vapid_key__|$PWA_FIREBASE_VAPID_KEY|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__logger_type__|$LOGGER_TYPE|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__sentry_dsn__|$SENTRY_DSN|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__social_auth_twitter_consumer_key___|$SOCIAL_AUTH_TWITTER_CONSUMER_KEY|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__social_auth_twitter_consumer_secret___|$SOCIAL_AUTH_TWITTER_CONSUMER_SECRET|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__social_auth_apple_client_id__|$SOCIAL_AUTH_APPLE_CLIENT_ID|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__social_auth_apple_android_redirect__|$SOCIAL_AUTH_APPLE_ANDROID_REDIRECT|" lib/src/app/service/app_settings_service.dart
 
    $sedCommand "s|__pwa_firebase_api_key___|$PWA_FIREBASE_API_KEY|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_auth_domain___|$PWA_FIREBASE_AUTH_DOMAIN|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_project_id___|$PWA_FIREBASE_PROJECT_ID|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_storage_bucket___|$PWA_FIREBASE_STORAGE_BUCKET|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_messaging_sender_id___|$PWA_FIREBASE_MESSAGING_SENDER_ID|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_analytics_measurement_id__|$PWA_FIREBASE_ANALYTICS_MEASUREMENT_ID|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_is_firebase_analytics_enabled__|$PWA_FIREBASE_ANALYTICS_ENABLED|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__pwa_firebase_app_id___|$PWA_FIREBASE_APP_ID|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__admob_android_app_id__|$ADMOB_ANDROID_APP_ID|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__admob_ios_app_id__|$ADMOB_IOS_APP_ID|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_hardcoded_white_color__|$THEME_COMMON_HARDCODED_WHITE_COLOR|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_hardcoded_black_color__|$THEME_COMMON_HARDCODED_BLACK_COLOR|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dangerous_color__|$THEME_COMMON_DANGEROUS_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dangerous_color_dark__|$THEME_COMMON_DANGEROUS_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_warning_color__|$THEME_COMMON_WARNING_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_warning_color_dark__|$THEME_COMMON_WARNING_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_system_icon_color__|$THEME_COMMON_SYSTEM_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_system_icon_color_dark__|$THEME_COMMON_SYSTEM_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_alert_icon_color__|$THEME_COMMON_ALERT_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_alert_icon_color_dark__|$THEME_COMMON_ALERT_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_success_icon_color__|$THEME_COMMON_SUCCESS_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_success_icon_color_dark__|$THEME_COMMON_SUCCESS_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_pending_icon_color__|$THEME_COMMON_PENDING_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_pending_icon_color_dark__|$THEME_COMMON_PENDING_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_text_color__|$THEME_COMMON_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_text_color_dark__|$THEME_COMMON_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_accent_color__|$THEME_COMMON_ACCENT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_accent_color_dark__|$THEME_COMMON_ACCENT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_gradient_start_color__|$THEME_COMMON_GRADIENT_START_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_gradient_start_color_dark__|$THEME_COMMON_GRADIENT_START_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_gradient_end_color__|$THEME_COMMON_GRADIENT_END_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_gradient_end_color_dark__|$THEME_COMMON_GRADIENT_END_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_icon_light_color__|$THEME_COMMON_ICON_LIGHT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_icon_light_color_dark__|$THEME_COMMON_ICON_LIGHT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_skeleton_color__|$THEME_COMMON_SKELETON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_skeleton_color_dark__|$THEME_COMMON_SKELETON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_skeleton_light_color__|$THEME_COMMON_SKELETON_LIGHT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_skeleton_light_color_dark__|$THEME_COMMON_SKELETON_LIGHT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_scaffold_default_color__|$THEME_COMMON_SCAFFOLD_DEFAULT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_scaffold_default_color_dark__|$THEME_COMMON_SCAFFOLD_DEFAULT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_scaffold_light_color__|$THEME_COMMON_SCAFFOLD_LIGHT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_scaffold_light_color_dark__|$THEME_COMMON_SCAFFOLD_LIGHT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_scaffold_bar_color__|$THEME_COMMON_SCAFFOLD_BAR_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_scaffold_bar_color_dark__|$THEME_COMMON_SCAFFOLD_BAR_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_app_bar_border_color__|$THEME_COMMON_APP_BAR_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_app_bar_border_color_dark__|$THEME_COMMON_APP_BAR_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_input_text_background_color__|$THEME_COMMON_INPUT_TEXT_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_input_text_background_color_dark__|$THEME_COMMON_INPUT_TEXT_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_form_text_color__|$THEME_COMMON_FORM_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_form_text_color_dark__|$THEME_COMMON_FORM_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_form_placeholder_color__|$THEME_COMMON_FORM_PLACEHOLDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_form_placeholder_color_dark__|$THEME_COMMON_FORM_PLACEHOLDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_form_value_color__|$THEME_COMMON_FORM_VALUE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_form_value_color_dark__|$THEME_COMMON_FORM_VALUE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_form_label_color__|$THEME_COMMON_FORM_LABEL_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_form_label_color_dark__|$THEME_COMMON_FORM_LABEL_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_form_section_color__|$THEME_COMMON_FORM_SECTION_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_form_section_color_dark__|$THEME_COMMON_FORM_SECTION_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_segmented_control_text_color__|$THEME_COMMON_SEGMENTED_CONTROL_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_segmented_control_text_color_dark__|$THEME_COMMON_SEGMENTED_CONTROL_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_alert_passive_icon_color__|$THEME_COMMON_ALERT_PASSIVE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_alert_passive_icon_color_dark__|$THEME_COMMON_ALERT_PASSIVE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_divider_color__|$THEME_COMMON_DIVIDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_divider_color_dark__|$THEME_COMMON_DIVIDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_info_item_label_color__|$THEME_COMMON_INFO_ITEM_LABEL_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_info_item_label_color_dark__|$THEME_COMMON_INFO_ITEM_LABEL_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_info_item_value_color__|$THEME_COMMON_INFO_ITEM_VALUE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_info_item_value_color_dark__|$THEME_COMMON_INFO_ITEM_VALUE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_select_arrow_color__|$THEME_COMMON_SELECT_ARROW_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_select_arrow_color_dark__|$THEME_COMMON_SELECT_ARROW_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_user_list_item_row_highlight_color__|$THEME_COMMON_USER_LIST_ITEM_ROW_HIGHLIGHT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_user_list_item_row_highlight_color_dark__|$THEME_COMMON_USER_LIST_ITEM_ROW_HIGHLIGHT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_user_card_online_color__|$THEME_COMMON_USER_CARD_ONLINE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_user_card_online_color_dark__|$THEME_COMMON_USER_CARD_ONLINE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_user_card_distance_color__|$THEME_COMMON_USER_CARD_DISTANCE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_user_card_distance_color_dark__|$THEME_COMMON_USER_CARD_DISTANCE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_blank_descr_color__|$THEME_COMMON_BLANK_DESCR_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_blank_descr_color_dark__|$THEME_COMMON_BLANK_DESCR_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_blank_title_color__|$THEME_COMMON_BLANK_TITLE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_blank_title_color_dark__|$THEME_COMMON_BLANK_TITLE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_form_input_background_color__|$THEME_COMMON_LOGIN_FORM_INPUT_BACKGROUND|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_form_input_background_color_dark__|$THEME_COMMON_LOGIN_FORM_INPUT_BACKGROUND_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_form_text_color__|$THEME_COMMON_LOGIN_FORM_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_form_text_color_dark__|$THEME_COMMON_LOGIN_FORM_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart
 
    $sedCommand "s|__theme_common_login_form_placeholder_color__|$THEME_COMMON_LOGIN_FORM_PLACEHOLDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_form_placeholder_color_dark__|$THEME_COMMON_LOGIN_FORM_PLACEHOLDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_label_color__|$THEME_COMMON_LOGIN_FIREBASE_LABEL_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_label_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_LABEL_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_divider_color__|$THEME_COMMON_LOGIN_FIREBASE_DIVIDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_divider_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_DIVIDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_inline_button_color__|$THEME_COMMON_LOGIN_INLINE_BUTTON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_inline_button_color_dark__|$THEME_COMMON_LOGIN_INLINE_BUTTON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_button_color__|$THEME_COMMON_LOGIN_BUTTON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_button_color_dark__|$THEME_COMMON_LOGIN_BUTTON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_facebook_icon_background_color__|$THEME_COMMON_LOGIN_FIREBASE_FACEBOOK_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_facebook_icon_background_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_FACEBOOK_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_google_icon_background_color__|$THEME_COMMON_LOGIN_FIREBASE_GOOGLE_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_google_icon_background_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_GOOGLE_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_twitter_icon_background_color__|$THEME_COMMON_LOGIN_FIREBASE_TWITTER_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_twitter_icon_background_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_TWITTER_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_login_firebase_apple_icon_background_color__|$THEME_COMMON_LOGIN_FIREBASE_APPLE_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_login_firebase_apple_icon_background_color_dark__|$THEME_COMMON_LOGIN_FIREBASE_APPLE_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_user_name_color__|$THEME_COMMON_DASHBOARD_PROFILE_USER_NAME_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_user_name_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_USER_NAME_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_user_desc_color__|$THEME_COMMON_DASHBOARD_PROFILE_USER_DESC_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_user_desc_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_USER_DESC_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_button_border_color__|$THEME_COMMON_DASHBOARD_PROFILE_BUTTON_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_button_border_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_BUTTON_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_link_color__|$THEME_COMMON_DASHBOARD_PROFILE_LINK_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_link_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_LINK_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_guide_background_color__|$THEME_COMMON_DASHBOARD_PROFILE_GUIDE_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_guide_background_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_GUIDE_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_guide_color__|$THEME_COMMON_DASHBOARD_PROFILE_GUIDE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_guide_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_GUIDE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_profile_notification_background_color__|$THEME_COMMON_DASHBOARD_PROFILE_NOTIFICATION_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_profile_notification_background_color_dark__|$THEME_COMMON_DASHBOARD_PROFILE_NOTIFICATION_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_menu_widget_passive_icon_color__|$THEME_COMMON_DASHBOARD_MENU_WIDGET_PASSIVE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_menu_widget_passive_icon_color_dark__|$THEME_COMMON_DASHBOARD_MENU_WIDGET_PASSIVE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_menu_widget_border_color__|$THEME_COMMON_DASHBOARD_MENU_WIDGET_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_menu_widget_border_color_dark__|$THEME_COMMON_DASHBOARD_MENU_WIDGET_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_edit_photo_slot_background_color__|$THEME_COMMON_EDIT_PHOTO_SLOT_BACKGROUND|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_edit_photo_slot_background_color_dark__|$THEME_COMMON_EDIT_PHOTO_SLOT_BACKGROUND_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_edit_photo_extra_slot_icon_color__|$THEME_COMMON_EDIT_PHOTO_EXTRA_SLOT_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_edit_photo_extra_slot_icon_color_dark__|$THEME_COMMON_EDIT_PHOTO_EXTRA_SLOT_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_edit_photo_approval_text_color__|$THEME_COMMON_EDIT_PHOTO_APPROVAL_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_edit_photo_approval_text_color_dark__|$THEME_COMMON_EDIT_PHOTO_APPROVAL_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_hot_list_empty_text_color__|$THEME_COMMON_HOT_LIST_EMPTY_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_hot_list_empty_text_color_dark__|$THEME_COMMON_HOT_LIST_EMPTY_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_hot_list_background_color__|$THEME_COMMON_HOT_LIST_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_hot_list_background_color_dark__|$THEME_COMMON_HOT_LIST_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_small_icon_border_color__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_small_icon_border_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_small_icon_color__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_small_icon_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_rewind_icon_background_color__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_REWIND_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_action_toolbar_widget_rewind_icon_background_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_REWIND_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_filters_background_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_FILTERS_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_filters_background_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_FILTERS_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_filters_border_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_FILTERS_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_filters_border_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_FILTERS_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_text_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_text_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_border_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_border_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_like_background_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_LIKE_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_like_background_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_LIKE_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_dislike_background_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_DISLIKE_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_swipe_dislike_background_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_SWIPE_DISLIKE_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_distance_color__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_DISTANCE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_dashboard_tinder_user_card_widget_distance_color_dark__|$THEME_COMMON_DASHBOARD_TINDER_USER_CARD_WIDGET_DISTANCE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_search_field_icons_color__|$THEME_COMMON_SEARCH_FIELD_ICONS_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_search_field_icons_color_dark__|$THEME_COMMON_SEARCH_FIELD_ICONS_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_search_field_background_color__|$THEME_COMMON_SEARCH_FIELD_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_search_field_background_color_dark__|$THEME_COMMON_SEARCH_FIELD_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_background_gradient_start_color__|$THEME_COMMON_MATCHED_USER_BACKGROUND_GRADIENT_START_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_background_gradient_start_color_dark__|$THEME_COMMON_MATCHED_USER_BACKGROUND_GRADIENT_START_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_background_gradient_end_color__|$THEME_COMMON_MATCHED_USER_BACKGROUND_GRADIENT_END_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_background_gradient_end_color_dark__|$THEME_COMMON_MATCHED_USER_BACKGROUND_GRADIENT_END_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_header_text_color__|$THEME_COMMON_MATCHED_USER_HEADER_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_header_text_color_dark__|$THEME_COMMON_MATCHED_USER_HEADER_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_desc_text_color__|$THEME_COMMON_MATCHED_USER_DESC_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_desc_text_color_dark__|$THEME_COMMON_MATCHED_USER_DESC_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_button_text_color__|$THEME_COMMON_MATCHED_USER_BUTTON_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_button_text_color_dark__|$THEME_COMMON_MATCHED_USER_BUTTON_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_matched_user_button_border_color__|$THEME_COMMON_MATCHED_USER_BUTTON_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_matched_user_button_border_color_dark__|$THEME_COMMON_MATCHED_USER_BUTTON_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_toolbar_wrapper_background_color__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_WRAPPER_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_toolbar_wrapper_background_color_dark__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_WRAPPER_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_toolbar_wrapper_shadow_color__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_WRAPPER_SHADOW_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_toolbar_wrapper_shadow_color_dark__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_WRAPPER_SHADOW_COLOR_DARK|" lib/src/app/service/app_settings_service.dart
 
    $sedCommand "s|__theme_common_profile_info_more_icon_color__|$THEME_COMMON_PROFILE_INFO_MORE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_info_more_icon_color_dark__|$THEME_COMMON_PROFILE_INFO_MORE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_photo_back_background_color__|$THEME_COMMON_PROFILE_PHOTO_BACK_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_photo_back_background_color_dark__|$THEME_COMMON_PROFILE_PHOTO_BACK_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_photo_pagination_shadow_color__|$THEME_COMMON_PROFILE_PHOTO_PAGINATION_SHADOW_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_photo_pagination_shadow_color_dark__|$THEME_COMMON_PROFILE_PHOTO_PAGINATION_SHADOW_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_photo_edit_button_background_color__|$THEME_COMMON_PROFILE_PHOTO_EDIT_BUTTON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_photo_edit_button_background_color_dark__|$THEME_COMMON_PROFILE_PHOTO_EDIT_BUTTON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_compatibility_bar_background_color__|$THEME_COMMON_PROFILE_COMPATIBILITY_BAR_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_compatibility_bar_background_color_dark__|$THEME_COMMON_PROFILE_COMPATIBILITY_BAR_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_video_chat_icon_background_color__|$THEME_COMMON_PROFILE_VIDEO_CHAT_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_video_chat_icon_background_color_dark__|$THEME_COMMON_PROFILE_VIDEO_CHAT_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_toolbar_like_icon_background_color__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_LIKE_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_toolbar_like_icon_background_color_dark__|$THEME_COMMON_PROFILE_ACTION_TOOLBAR_LIKE_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_preview_photos_close_icon_color__|$THEME_COMMON_PREVIEW_PHOTOS_CLOSE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_preview_photos_close_icon_color_dark__|$THEME_COMMON_PREVIEW_PHOTOS_CLOSE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_preview_photos_background_color__|$THEME_COMMON_PREVIEW_PHOTOS_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_preview_photos_background_color_dark__|$THEME_COMMON_PREVIEW_PHOTOS_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_1_color__|$THEME_COMMON_PROFILE_ACTION_1_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_1_color_dark__|$THEME_COMMON_PROFILE_ACTION_1_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_2_color__|$THEME_COMMON_PROFILE_ACTION_2_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_2_color_dark__|$THEME_COMMON_PROFILE_ACTION_2_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_3_color__|$THEME_COMMON_PROFILE_ACTION_3_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_3_color_dark__|$THEME_COMMON_PROFILE_ACTION_3_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_profile_action_text_color__|$THEME_COMMON_PROFILE_ACTION_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_profile_action_text_color_dark__|$THEME_COMMON_PROFILE_ACTION_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_message_chat_scroller_icon_color__|$THEME_COMMON_MESSAGE_CHAT_SCROLLER_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_scroller_icon_color_dark__|$THEME_COMMON_MESSAGE_CHAT_SCROLLER_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_message_chat_date_color__|$THEME_COMMON_MESSAGE_CHAT_DATE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_date_color_dark__|$THEME_COMMON_MESSAGE_CHAT_DATE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_message_chat_wink_time_color__|$THEME_COMMON_MESSAGE_CHAT_WINK_TIME_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_wink_time_color_dark__|$THEME_COMMON_MESSAGE_CHAT_WINK_TIME_COLOR_DARK|" lib/src/app/service/app_settings_service.dart
 
    $sedCommand "s|__theme_common_message_chat_wink_received_icon_color__|$THEME_COMMON_MESSAGE_CHAT_WINK_RECEIVED_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_wink_received_icon_color_dark__|$THEME_COMMON_MESSAGE_CHAT_WINK_RECEIVED_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_message_chat_attachment_icon_color__|$THEME_COMMON_MESSAGE_CHAT_ATTACHMENT_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_attachment_icon_color_dark__|$THEME_COMMON_MESSAGE_CHAT_ATTACHMENT_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_message_chat_promoted_content_color__|$THEME_COMMON_MESSAGE_CHAT_PROMOTED_CONTENT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_message_chat_promoted_content_color_dark__|$THEME_COMMON_MESSAGE_CHAT_PROMOTED_CONTENT_COLOR|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_video_im_call_widget_wrapper_background_color__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_WRAPPER_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_call_widget_wrapper_background_color_dark__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_WRAPPER_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_video_im_call_widget_no_answer_text_color__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_NO_ANSWER_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_call_widget_no_answer_text_color_dark__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_NO_ANSWER_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart
 
    $sedCommand "s|__theme_common_video_im_call_widget_local_video_shadow_color__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_LOCAL_VIDEO_SHADOW_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_call_widget_local_video_shadow_color_dark__|$THEME_COMMON_VIDEO_IM_CALL_WIDGET_LOCAL_VIDEO_SHADOW_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_video_im_widget_blur_overlay_background_color__|$THEME_COMMON_VIDEO_IM_WIDGET_BLUR_OVERLAY_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_widget_blur_overlay_background_color_dark__|$THEME_COMMON_VIDEO_IM_WIDGET_BLUR_OVERLAY_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_video_im_widget_call_phone_icon_color__|$THEME_COMMON_VIDEO_IM_WIDGET_CALL_PHONE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_widget_call_phone_icon_color_dark__|$THEME_COMMON_VIDEO_IM_WIDGET_CALL_PHONE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_video_im_widget_end_call_phone_icon_color__|$THEME_COMMON_VIDEO_IM_WIDGET_END_CALL_PHONE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_video_im_widget_end_call_phone_icon_color_dark__|$THEME_COMMON_VIDEO_IM_WIDGET_END_CALL_PHONE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_payment_billing_gateway_border_color__|$THEME_COMMON_PAYMENT_BILLING_GATEWAY_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_payment_billing_gateway_border_color_dark__|$THEME_COMMON_PAYMENT_BILLING_GATEWAY_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_payment_initial_highlight_color__|$THEME_COMMON_PAYMENT_INITIAL_HIGHLIGHT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_payment_initial_highlight_color_dark__|$THEME_COMMON_PAYMENT_INITIAL_HIGHLIGHT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_payment_order_processing_page_icon_color__|$THEME_COMMON_PAYMENT_ORDER_PROCESSING_PAGE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_payment_order_processing_page_icon_color_dark__|$THEME_COMMON_PAYMENT_ORDER_PROCESSING_PAGE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_toaster_text_color__|$THEME_COMMON_TOASTER_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_toaster_text_color_dark__|$THEME_COMMON_TOASTER_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_common_toaster_background_color__|$THEME_COMMON_TOASTER_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_common_toaster_background_color_dark__|$THEME_COMMON_TOASTER_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_login_form_input_icon_color__|$THEME_CUSTOM_LOGIN_FORM_INPUT_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_login_form_input_icon_color_dark__|$THEME_CUSTOM_LOGIN_FORM_INPUT_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_login_form_button_background_color__|$THEME_CUSTOM_LOGIN_FORM_BUTTON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_login_form_button_background_color_dark__|$THEME_CUSTOM_LOGIN_FORM_BUTTON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_button_background_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_BUTTON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_button_background_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_BUTTON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_button_text_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_BUTTON_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_button_text_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_BUTTON_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_wrapper_background_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_WRAPPER_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_wrapper_background_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_WRAPPER_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_background_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_background_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_shadow_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_SHADOW_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_shadow_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_SHADOW_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_avatar_background_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_AVATAR_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_avatar_background_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_AVATAR_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_border_color__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_profile_info_wrapper_border_color_dark__|$THEME_CUSTOM_DASHBOARD_PROFILE_INFO_WRAPPER_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_notification_background_color__|$THEME_CUSTOM_NOTIFICATION_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_notification_background_color_dark__|$THEME_CUSTOM_NOTIFICATION_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_profile_compatibility_bar_main_background_color__|$THEME_CUSTOM_PROFILE_COMPATIBILITY_BAR_MAIN_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_profile_compatibility_bar_main_background_color_dark__|$THEME_CUSTOM_PROFILE_COMPATIBILITY_BAR_MAIN_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_dislike_icon_background_color__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_DISLIKE_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_dislike_icon_background_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_DISLIKE_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_dislike_icon_color__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_DISLIKE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_dislike_icon_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_DISLIKE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_active_color__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_ACTIVE_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_active_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_ACTIVE_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_background_color__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_background_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_active_background_color__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_ACTIVE_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_action_toolbar_widget_small_icon_active_background_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_ACTION_TOOLBAR_WIDGET_SMALL_ICON_ACTIVE_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_loading_widget_radar_start_color__|$THEME_CUSTOM_DASHBOARD_TINDER_LOADING_WIDGET_RADAR_START_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_loading_widget_radar_start_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_LOADING_WIDGET_RADAR_START_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_tinder_loading_widget_radar_end_color__|$THEME_CUSTOM_DASHBOARD_TINDER_LOADING_WIDGET_RADAR_END_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_tinder_loading_widget_radar_end_color_dark__|$THEME_CUSTOM_DASHBOARD_TINDER_LOADING_WIDGET_RADAR_END_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_matched_send_message_button_background_color__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_BUTTON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_matched_send_message_button_background_color_dark__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_BUTTON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_matched_send_message_button_text_color__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_BUTTON_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_matched_send_message_button_text_color_dark__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_BUTTON_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_matched_send_message_icon_color__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_matched_send_message_icon_color_dark__|$THEME_CUSTOM_MATCHED_SEND_MESSAGE_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_border_color__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BORDER_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_border_color_dark__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BORDER_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_background_color__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_background_color_dark__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_color__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_profile_action_toolbar_widget_small_icon_color_dark__|$THEME_CUSTOM_PROFILE_ACTION_TOOLBAR_WIDGET_SMALL_ICON_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_conversation_list_background_color__|$THEME_CUSTOM_DASHBOARD_CONVERSATION_LIST_BACKGROUND_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_conversation_list_background_color_dark__|$THEME_CUSTOM_DASHBOARD_CONVERSATION_LIST_BACKGROUND_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    $sedCommand "s|__theme_custom_dashboard_conversation_list_preview_text_color__|$THEME_CUSTOM_DASHBOARD_CONVERSATION_LIST_PREVIEW_TEXT_COLOR|" lib/src/app/service/app_settings_service.dart
    $sedCommand "s|__theme_custom_dashboard_conversation_list_preview_text_color_dark__|$THEME_CUSTOM_DASHBOARD_CONVERSATION_LIST_PREVIEW_TEXT_COLOR_DARK|" lib/src/app/service/app_settings_service.dart

    rm -rf lib/src/app/service/app_settings_service.dart.backup

    # build the PWA manifest file -  "web/manifest.json"
    cp config/platform/web/manifest.json.tmpl web/manifest.json
    $sedCommand "s|__name___|$NAME|" web/manifest.json
    $sedCommand "s|__short_name___|$SHORT_NAME|" web/manifest.json
    $sedCommand "s|__background_color___|$SPLASH_SCREEN_BACKGROUND|" web/manifest.json
    $sedCommand "s|__desc___|$DESCRIPTION|" web/manifest.json
    $sedCommand "s|__pwa_icon_512__|$PWA_ICON_512|" web/manifest.json
    $sedCommand "s|__pwa_icon_192__|$PWA_ICON_192|" web/manifest.json
    rm -rf web/manifest.json.backup

    # build the PWA index.html file - "web/index.html"
    cp -f config/platform/web/index.html.tmpl web/index.html
    $sedCommand "s|__name__|$NAME|" web/index.html
    $sedCommand "s|__description__|$DESCRIPTION|" web/index.html
    $sedCommand "s|__apple_icon__|$PWA_APPLE_ICON|" web/index.html
    $sedCommand "s|__fav_icon__|$PWA_FAV_ICON|" web/index.html
    $sedCommand "s|__pwa_firebase_api_key__|$PWA_FIREBASE_API_KEY|" web/index.html
    $sedCommand "s|__pwa_firebase_auth_domain__|$PWA_FIREBASE_AUTH_DOMAIN|" web/index.html
    $sedCommand "s|__pwa_firebase_project_id__|$PWA_FIREBASE_PROJECT_ID|" web/index.html
    $sedCommand "s|__pwa_firebase_storage_bucket__|$PWA_FIREBASE_STORAGE_BUCKET|" web/index.html
    $sedCommand "s|__pwa_firebase_messaging_sender_id__|$PWA_FIREBASE_MESSAGING_SENDER_ID|" web/index.html
    $sedCommand "s|__pwa_firebase_analytics_measurement_id__|$PWA_FIREBASE_ANALYTICS_MEASUREMENT_ID|" web/index.html
    $sedCommand "s|__pwa_firebase_app_id__|$PWA_FIREBASE_APP_ID|" web/index.html
    $sedCommand "s|__pwa_firebase_vapid_key__|$PWA_FIREBASE_VAPID_KEY|" web/index.html
    $sedCommand "s|__splash_screen_image__|$SPLASH_SCREEN_IMAGE|" web/index.html
    $sedCommand "s|__splash_screen_image_dark__|$SPLASH_SCREEN_IMAGE_DARK|" web/index.html
    $sedCommand "s|__social_auth_facebook_app_id__|$SOCIAL_AUTH_FACEBOOK_APP_ID|" web/index.html
    rm -rf web/index.html.backup

    # copy splash screen styles
    cp -f config/platform/web/splash.css.tmpl web/splash.css
    $sedCommand "s|__splash_screen_background__|$SPLASH_SCREEN_BACKGROUND|" web/splash.css
    $sedCommand "s|__splash_screen_background_dark__|$SPLASH_SCREEN_BACKGROUND_DARK|" web/splash.css
    $sedCommand "s|__splash_screen_width_pwa__|$SPLASH_SCREEN_WIDTH_PWA|" web/splash.css
    rm -rf web/splash.css.backup

    # copy orientation screen styles
    cp -f config/platform/web/orientation.css.tmpl web/orientation.css
    $sedCommand "s|__splash_screen_background__|$SPLASH_SCREEN_BACKGROUND|" web/orientation.css
    $sedCommand "s|__splash_screen_background_dark__|$SPLASH_SCREEN_BACKGROUND_DARK|" web/orientation.css
    rm -rf web/orientation.css.backup

    # copy facebook auth web handler
    cp -f config/platform/web/flutter_facebook_auth.js.tmpl web/flutter_facebook_auth.js

    # build the Firebase Messaging Service Worker
    cp -f config/platform/web/firebase-messaging.sw-merge.js.tmpl web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_api_key__|$PWA_FIREBASE_API_KEY|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_auth_domain__|$PWA_FIREBASE_AUTH_DOMAIN|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_project_id__|$PWA_FIREBASE_PROJECT_ID|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_storage_bucket__|$PWA_FIREBASE_STORAGE_BUCKET|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_messaging_sender_id__|$PWA_FIREBASE_MESSAGING_SENDER_ID|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_analytics_measurement_id__|$PWA_FIREBASE_ANALYTICS_MEASUREMENT_ID|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_app_id__|$PWA_FIREBASE_APP_ID|" web/firebase-messaging.sw-merge.js
    $sedCommand "s|__pwa_firebase_vapid_key__|$PWA_FIREBASE_VAPID_KEY|" web/firebase-messaging.sw-merge.js
    rm -rf web/firebase-messaging.sw-merge.js.backup

    # copy dummy service worker
    cp -f config/platform/web/firebase-messaging-sw.js.tmpl web/firebase-messaging-sw.js

    # copy platform.min.js
    cp -f config/platform/web/platform.min.js web/platform.min.js

    [[ $API_PROTOCOL = "https" ]] && allowHttp="false" || allowHttp="true"

    # update iOS-specific settings
    echo "Change IOS settings"

    # update `IOS` specific settings
    iosGoogleReserverClientId=`xmllint --xpath "//dict/string[2]/text()" config/platform/ios/GoogleService-Info.plist`

    xmllint --shell ios/Runner/Info.plist &>/dev/null << EOF
        cd //dict/key[text()="NSAppTransportSecurity"]/following-sibling::dict[1]
        set <key>NSAllowsArbitraryLoads</key><$allowHttp/>

        cd //dict/key[text()="CFBundleDisplayName"]/following-sibling::string[1]
        set $NAME

        cd //dict/key[text()="FacebookAppID"]/following-sibling::string[1]
        set $SOCIAL_AUTH_FACEBOOK_APP_ID

        cd //dict/array/dict[key="CFBundleURLSchemes"]/array/string[1]
        set twitterkit-$SOCIAL_AUTH_TWITTER_CONSUMER_KEY

        cd //dict/array/dict[key="CFBundleURLSchemes"]/array/string[2]
        set $iosGoogleReserverClientId

        cd //dict/array/dict[key="CFBundleURLSchemes"]/array/string[3]
        set fb$SOCIAL_AUTH_FACEBOOK_APP_ID

        cd //dict/key[text()="GADApplicationIdentifier"]/following-sibling::string[1]
        set $ADMOB_IOS_APP_ID

        save
EOF

    xmllint --shell ios/Runner/Runner.entitlements &>/dev/null << EOF
        cd //dict/key[text()="com.apple.developer.associated-domains"]/following-sibling::array[1]/string
        set applinks:$API_DOMAIN

        save
EOF

    xmllint --shell ios/Runner/RunnerDebug.entitlements &>/dev/null << EOF
        cd //dict/key[text()="com.apple.developer.associated-domains"]/following-sibling::array[1]/string
        set applinks:$API_DOMAIN

        save
EOF

    xmllint --shell ios/Runner/RunnerRelease.entitlements &>/dev/null << EOF
        cd //dict/key[text()="com.apple.developer.associated-domains"]/following-sibling::array[1]/string
        set applinks:$API_DOMAIN

        save
EOF

    $sedCommand "s/\PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_NAME;/g" ios/Runner.xcodeproj/project.pbxproj
    $sedCommand "s/\MARKETING_VERSION = .*;/MARKETING_VERSION = $VERSION;/g" ios/Runner.xcodeproj/project.pbxproj
    $sedCommand "s/\CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $VERSION_BUILD;/g" ios/Runner.xcodeproj/project.pbxproj
    rm -rf ios/Runner.xcodeproj/project.pbxproj.backup


    # update Android-specific settings
    echo "Change Android settings"

    [[ -f "config/platform/android/google-services.json" ]] && \
      cp config/platform/android/google-services.json android/app/google-services.json

    cp -f config/platform/android/strings_generated.xml.tmpl android/app/src/main/res/values/strings_generated.xml
    $sedCommand "s/__app_name__/$NAME/" android/app/src/main/res/values/strings_generated.xml
    $sedCommand "s/__facebook_app_id__/$SOCIAL_AUTH_FACEBOOK_APP_ID/" android/app/src/main/res/values/strings_generated.xml
    $sedCommand "s/__facebook_login_protocol_scheme__/$SOCIAL_AUTH_FACEBOOK_LOGIN_PROTOCOL_SCHEME/" android/app/src/main/res/values/strings_generated.xml
    $sedCommand "s/__admob_android_app_id__/$ADMOB_ANDROID_APP_ID/" android/app/src/main/res/values/strings_generated.xml
    rm android/app/src/main/res/values/strings_generated.xml.backup

    cp -f config/platform/android/colors_generated.xml.tmpl android/app/src/main/res/values/colors_generated.xml
    $sedCommand "s/__android_push_notification_icon_color__/$ANDROID_PUSH_NOTIFICATION_ICON_COLOR/" android/app/src/main/res/values/colors_generated.xml
    rm android/app/src/main/res/values/colors_generated.xml.backup

    cp -f config/platform/android/build.gradle.tmpl android/app/build.gradle
    $sedCommand "s/__bundle_name__/$BUNDLE_NAME/g" android/app/build.gradle
    $sedCommand "s/__version__/$VERSION/g" android/app/build.gradle
    $sedCommand "s/__version_build__/$VERSION_BUILD/g" android/app/build.gradle
    rm -rf android/app/build.gradle.backup

    $sedCommand "s/\package=\".*\"/\package=\"$BUNDLE_NAME\"/g" android/app/src/debug/AndroidManifest.xml
    rm -rf android/app/src/debug/AndroidManifest.xml.backup

    $sedCommand "s/\package=\".*\"/\package=\"$BUNDLE_NAME\"/g" android/app/src/profile/AndroidManifest.xml
    rm -rf android/app/src/profile/AndroidManifest.xml.backup

    $sedCommand "s/\package=\".*\"/\package=\"$BUNDLE_NAME\"/g" android/app/src/main/AndroidManifest.xml
    $sedCommand "s/\usesCleartextTraffic=\".*\"/\usesCleartextTraffic=\"$allowHttp\"/g" android/app/src/main/AndroidManifest.xml
    $sedCommand "s/\android:host=\".*\"/\android:host=\"$API_DOMAIN\"/g" android/app/src/main/AndroidManifest.xml
    rm -rf android/app/src/main/AndroidManifest.xml.backup

    cp -f config/platform/android/key.properties.tmpl android/key.properties
    $sedCommand "s/__store_password__/$ANDROID_RELEASE_KEYSTORE_PASSWORD/g" android/key.properties
    $sedCommand "s/__key_password__/$ANDROID_RELEASE_KEYSTORE_PASSWORD/g" android/key.properties
    $sedCommand "s/__key_alias__/$ANDROID_RELEASE_KEY_ALIAS/g" android/key.properties
    $sedCommand "s|__store_file__|$ANDROID_RELEASE_KEYSTORE_FILE_PATH|g" android/key.properties
    rm -rf android/key.properties.backup

    # create main activity at the new bundle path
    bundlePathFragment=$(echo "$BUNDLE_NAME" | sed "s/\./\//g")
    bundlePath="android/app/src/main/kotlin/$bundlePathFragment"
    mainActivityPath="$bundlePath/MainActivity.kt"

    if [[ ! -f $mainActivityPath ]]; then
        echo "Creating MainActivity.kt at $bundlePath"

        rm -rf android/app/src/main/kotlin/*
        mkdir -p -v "$bundlePath"
        cp config/platform/android/MainActivity.kt.tmpl "$mainActivityPath"

        # replace variable with actual bundle ID
        $sedCommand "s|__bundle_name__|$BUNDLE_NAME|" "$mainActivityPath"
        rm -f "$mainActivityPath.backup"
    fi

    # Generate splashscreens and launch icons

    echo "Generate splash and launch icons"

    # create a config file for generating a splash screen
    echo "flutter_native_splash:" > flutter_native_splash.yaml
    echo "  image: $SPLASH_SCREEN_IMAGE" >> flutter_native_splash.yaml
    echo "  color: $SPLASH_SCREEN_BACKGROUND" >> flutter_native_splash.yaml
    echo "  image_dark: $SPLASH_SCREEN_IMAGE_DARK" >> flutter_native_splash.yaml
    echo "  color_dark: $SPLASH_SCREEN_BACKGROUND_DARK" >> flutter_native_splash.yaml
    echo "  web: false" >> flutter_native_splash.yaml

    # copy splashscreen to both Android and IOS
    flutter pub pub run flutter_native_splash:create

    # create a config file for generating launch icons
    echo "flutter_icons:" > flutter_launcher_icons.yaml
    echo "  android: true" >> flutter_launcher_icons.yaml
    echo "  ios: true" >> flutter_launcher_icons.yaml
    echo "  image_path: $LAUNCH_ICON_ANDROID" >> flutter_launcher_icons.yaml
    echo "  image_path_ios: $LAUNCH_ICON_IOS" >> flutter_launcher_icons.yaml

    # copy launch icons to both Android and IOS
    flutter pub run flutter_launcher_icons:main
fi

# CLEAN THE PROJECT
if [[ $inputCommand == "clean" ]]; then
  echo "Cleaning the project"

  flutter clean

  echo "Removing generated files"

  # shellcheck disable=SC2046
  rm -f -v $(find ./lib -depth -iname "*.g.dart")
fi
