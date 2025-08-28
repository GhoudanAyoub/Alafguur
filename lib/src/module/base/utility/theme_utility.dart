import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../app/service/app_settings_service.dart';

bool isDarkMode() {
  final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

  return brightness == Brightness.dark;
}

MaterialAppData getAndroidTheme() {
  return MaterialAppData(
    theme: ThemeData(
        primarySwatch:
            customMaterialColor(AppSettingsService.themeCommonAccentColor),
        primaryColor: AppSettingsService.themeCommonScaffoldBarColor,
        colorScheme: ColorScheme.light(
          primary: AppSettingsService.themeCommonAccentColor,
          secondary: AppSettingsService.themeCommonAccentColor,
          brightness: AppSettingsService.isDarkMode
              ? Brightness.dark
              : Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppSettingsService.themeCommonScaffoldBarColor,
          titleTextStyle:
              TextStyle(color: AppSettingsService.themeCommonTextColor),
        ),
        dividerColor: AppSettingsService.themeCommonDividerColor,
        scaffoldBackgroundColor:
            AppSettingsService.themeCommonScaffoldDefaultColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
                AppSettingsService.themeCommonAccentColor),
            foregroundColor: WidgetStateProperty.all(
                AppSettingsService.themeCommonHardcodedWhiteColor),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(
                AppSettingsService.themeCommonAccentColor),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppSettingsService.themeCommonAccentColor,
          inactiveTrackColor:
              AppSettingsService.themeCommonAccentColor.withAlpha(128),
          thumbColor: AppSettingsService.themeCommonAccentColor,
        )),
    darkTheme: ThemeData(
      primarySwatch:
          customMaterialColor(AppSettingsService.themeCommonAccentColor),
      primaryColorDark: AppSettingsService.themeCommonScaffoldBarColor,
      colorScheme: ColorScheme.dark(
        primary: AppSettingsService.themeCommonAccentColor,
        secondary: AppSettingsService.themeCommonAccentColor,
        brightness: Brightness.dark,
        surface: AppSettingsService.themeCommonScaffoldLightColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppSettingsService.themeCommonScaffoldBarColor,
        titleTextStyle:
            TextStyle(color: AppSettingsService.themeCommonTextColor),
      ),
      canvasColor: AppSettingsService.themeCommonScaffoldDefaultColor,
      dialogBackgroundColor: AppSettingsService.themeCommonScaffoldDefaultColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              AppSettingsService.themeCommonAccentColor),
          foregroundColor: WidgetStateProperty.all(
              AppSettingsService.themeCommonHardcodedWhiteColor),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        bodyLarge: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        titleMedium: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        titleSmall: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        titleLarge: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        headlineSmall: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        headlineMedium: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        displaySmall: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        displayMedium: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
        displayLarge: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
      ),
      primaryTextTheme: TextTheme(
        titleLarge: TextStyle(
          color: AppSettingsService.themeCommonTextColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppSettingsService.themeCommonInputTextBackgroundColor,
      ), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return AppSettingsService.themeCommonAccentColor; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return AppSettingsService.themeCommonAccentColor; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return AppSettingsService.themeCommonAccentColor; }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return AppSettingsService.themeCommonAccentColor; }
 return null;
 }),
 ),
    ),
  );
}

CupertinoAppData getIosTheme() {
  return CupertinoAppData(
    theme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        primaryColor: AppSettingsService.themeCommonAccentColor,
      ),
      primaryColor: AppSettingsService.themeCommonAccentColor,
      primaryContrastingColor:
          AppSettingsService.themeCommonHardcodedWhiteColor,
      barBackgroundColor: AppSettingsService.themeCommonScaffoldBarColor,
      scaffoldBackgroundColor:
          AppSettingsService.themeCommonScaffoldDefaultColor,
      brightness:
          AppSettingsService.isDarkMode ? Brightness.dark : Brightness.light,
    ),
  );
}

MaterialColor customMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  final Map<int, Color> swatch = <int, Color>{};
  final int r = ((color.red * 255.0).round() & 0xFF);
  final int g = ((color.green * 255.0).round() & 0xFF);
  final int b = ((color.blue * 255.0).round() & 0xFF);

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  
  for (double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  
  return MaterialColor(color.toARGB32(), swatch);
}
