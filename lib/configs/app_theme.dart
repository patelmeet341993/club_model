/*
* File : App Theme
* Version : 1.0.0
* */

import 'package:club_model/club_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  final Styles styles;

  const AppTheme({required this.styles});

  static TextStyle getTextStyle(
    TextStyle textStyle, {
    FontWeight fontWeight = FontWeight.w400,
    bool muted = false,
    bool xMuted = false,
    double letterSpacing = 0.15,
    Color? color,
    TextDecoration decoration = TextDecoration.none,
    double? height,
    double wordSpacing = 0,
    double? fontSize,
  }) {
    double finalFontSize = (fontSize ?? textStyle.fontSize) ?? 10;

    Color finalColor;
    if (color == null) {
      finalColor = (xMuted ? textStyle.color?.withAlpha(160) : (muted ? textStyle.color?.withAlpha(200) : textStyle.color)) ?? Colors.black;
    } else {
      finalColor = xMuted ? color.withAlpha(160) : (muted ? color.withAlpha(200) : color);
    }

    return getTextStyleWithFontFamily(
      textStyle: TextStyle(
        fontSize: finalFontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: finalColor,
        decoration: decoration,
        height: height,
        wordSpacing: wordSpacing,
      ),
    );
  }

  static TextStyle getTextStyleWithFontFamily({TextStyle? textStyle}) {
    // return (textStyle ?? TextStyle()).copyWith(fontFamily: "Mono");
    return GoogleFonts.catamaran(textStyle: textStyle);
  }

  static TextTheme getTextTheme({required Color color}) {
    return TextTheme(
      displayLarge: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 102, color: color)),
      displayMedium: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 64, color: color)),
      displaySmall: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 51, color: color)),
      headlineLarge: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 43, color: color)),
      headlineMedium: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 36, color: color)),
      headlineSmall: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 25, color: color)),
      titleLarge: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 18, color: color)),
      titleMedium: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 17, color: color)),
      titleSmall: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 15, color: color)),
      bodyLarge: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 16, color: color)),
      bodyMedium: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 14, color: color)),
      bodySmall: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 12, color: color)),
      labelLarge: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 15, color: color)),
      labelMedium: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 13, color: color)),
      labelSmall: getTextStyleWithFontFamily(textStyle: TextStyle(fontSize: 11, color: color, letterSpacing: 0)),
    );
  }

  //region App Bar Text
  TextTheme getLightAppBarTextTheme() {
    Color color = styles.lightAppBarTextColor;

    return getTextTheme(color: color);
  }

  TextTheme getDarkAppBarTextTheme() {
    Color color = styles.darkAppBarTextColor;

    return getTextTheme(color: color);
  }

  //endregion

  //region Text Themes
  TextTheme getLightTextTheme() {
    Color color = styles.lightTextColor;

    return getTextTheme(color: color);
  }

  TextTheme getDarkTextTheme() {
    Color color = styles.darkTextColor;

    return getTextTheme(color: color);
  }

  //endregion

  //region Color Themes
  ThemeData getLightTheme() {
    Color appBarTextColor = styles.lightAppBarTextColor;
    TextTheme lightAppBarTextTheme = getTextTheme(color: appBarTextColor);

    TextTheme lightTextTheme = getLightTextTheme();

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: styles.lightPrimaryColor,
      canvasColor: styles.lightBackgroundColor,
      scaffoldBackgroundColor: styles.lightBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: lightAppBarTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        toolbarTextStyle: lightAppBarTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        actionsIconTheme: IconThemeData(
          color: appBarTextColor,
        ),
        color: styles.lightAppBarColor,
        iconTheme: IconThemeData(color: appBarTextColor, size: 24),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: styles.lightPrimaryColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: styles.lightPrimaryColor,
        textTheme: ButtonTextTheme.normal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styles.buttonBorderRadius),
        ),
      ),
      dialogBackgroundColor: styles.lightBackgroundColor,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        selectedIconTheme: IconThemeData(
          color: styles.lightPrimaryColor,
          opacity: 1,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: styles.lightTextColor,
          opacity: 1,
          size: 24,
        ),
        backgroundColor: styles.lightBackgroundColor,
        elevation: 3,
        selectedLabelTextStyle: TextStyle(color: styles.lightPrimaryColor),
        unselectedLabelTextStyle: TextStyle(color: styles.lightTextColor),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.4),
        elevation: 1,
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(fontSize: 15, color: Color(0xaa495057)),
        labelStyle: lightTextTheme.bodyMedium,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: styles.lightPrimaryColor),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.black54),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.black54),
        ),
      ),
      splashColor: Colors.white.withAlpha(100),
      iconTheme: const IconThemeData(
        color: Colors.black,
        size: 26,
      ),
      textTheme: lightTextTheme,
      indicatorColor: Colors.white,
      disabledColor: const Color(0xffdcc7ff),
      highlightColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: styles.lightPrimaryColor,
        splashColor: Colors.white.withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: styles.lightPrimaryColor,
        hoverColor: styles.lightPrimaryColor,
        foregroundColor: Colors.white,
      ),
      dividerColor: const Color(0xffd1d1d1),
      cardColor: Colors.white,
      popupMenuTheme: PopupMenuThemeData(
        color: styles.lightBackgroundColor,
        textStyle: lightTextTheme.bodyMedium?.merge(TextStyle(color: styles.lightTextColor)),
      ),
      bottomAppBarTheme: BottomAppBarTheme(color: styles.lightBackgroundColor, elevation: 2),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: styles.lightTextColor,
        labelColor: styles.lightPrimaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: styles.lightPrimaryColor, width: 2.0),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: styles.lightPrimaryColor,
        inactiveTrackColor: styles.lightPrimaryColor.withAlpha(140),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: styles.lightPrimaryColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: styles.lightBackgroundColor,
      ),
      colorScheme: ColorScheme.light(
        primary: styles.lightPrimaryColor,
        onPrimary: Colors.white,
        primaryContainer: styles.lightPrimaryVariant,
        secondary: styles.lightSecondaryColor,
        secondaryContainer: styles.lightSecondaryVariant,
        onSecondary: Colors.white,
        surface: const Color(0xffe2e7f1),
        background: const Color(0xfff3f4f7),
        onBackground: styles.lightTextColor,
        error: const Color(0xfff0323c),
      ).copyWith(background: Colors.white),
    );
  }

  ThemeData getDarkTheme() {
    Color appBarTextColor = styles.darkAppBarTextColor;
    TextTheme lightAppBarTextTheme = getTextTheme(color: appBarTextColor);

    TextTheme darkTextTheme = getDarkTextTheme();

    return ThemeData(
      brightness: Brightness.dark,
      canvasColor: styles.darkBackgroundColor,
      primaryColor: styles.darkPrimaryColor,
      scaffoldBackgroundColor: styles.darkBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: lightAppBarTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        toolbarTextStyle: lightAppBarTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        actionsIconTheme: IconThemeData(
          color: appBarTextColor,
        ),
        color: styles.darkAppBarColor,
        iconTheme: IconThemeData(color: appBarTextColor, size: 24),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: styles.darkPrimaryColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: styles.darkPrimaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      dialogBackgroundColor: styles.darkBackgroundColor,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: styles.darkPrimaryColor, opacity: 1, size: 24),
        unselectedIconTheme: IconThemeData(color: styles.darkTextColor, opacity: 1, size: 24),
        backgroundColor: styles.darkBackgroundColor,
        elevation: 3,
        selectedLabelTextStyle: TextStyle(color: styles.darkPrimaryColor),
        unselectedLabelTextStyle: TextStyle(color: styles.darkTextColor),
      ),
      cardTheme: const CardTheme(
        color: Color(0xff37404a),
        shadowColor: Color(0xff000000),
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: darkTextTheme,
      indicatorColor: Colors.white,
      disabledColor: const Color(0xffa3a3a3),
      highlightColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: darkTextTheme.titleMedium,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Color(0xff10bbf0)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.white70),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.white70),
        ),
      ),
      dividerColor: const Color(0xffd1d1d1),
      cardColor: const Color(0xff282a2b),
      splashColor: Colors.white.withAlpha(100),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: styles.darkPrimaryColor,
        splashColor: Colors.white.withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: styles.darkPrimaryColor,
        hoverColor: styles.darkPrimaryColor,
        foregroundColor: Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xff37404a),
        textStyle: darkTextTheme.bodyMedium?.merge(TextStyle(color: styles.darkTextColor)),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xff292929), elevation: 2),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: styles.lightTextColor,
        labelColor: const Color(0xff10bbf0),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xff10bbf0), width: 2.0),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xff10bbf0),
        inactiveTrackColor: styles.darkPrimaryColor.withAlpha(100),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: const Color(0xff10bbf0),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(),
      colorScheme: ColorScheme.dark(
        primary: styles.darkPrimaryColor,
        primaryContainer: styles.darkPrimaryVariant,
        secondary: styles.darkSecondaryColor,
        secondaryContainer: styles.darkSecondaryVariant,
        background: Colors.black,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSecondary: Colors.white,
        surface: const Color(0xff585e63),
        error: Colors.orange,
      ).copyWith(background: Colors.black),
    );
  }

  //endregion

  ThemeData getThemeFromThemeMode(bool isDarkThemeEnabled) {
    if (isDarkThemeEnabled) {
      return getDarkTheme();
    } else {
      return getLightTheme();
    }
  }
}

class CustomAppTheme {
  final Color bgLayer1, bgLayer2, bgLayer3, bgLayer4, disabledColor, onDisabled, colorInfo, colorWarning, colorSuccess, colorError, shadowColor, onInfo, onWarning, onSuccess, onError;

  CustomAppTheme({
    this.bgLayer1 = const Color(0xffffffff),
    this.bgLayer2 = const Color(0xfff8faff),
    this.bgLayer3 = const Color(0xffeef2fa),
    this.bgLayer4 = const Color(0xffdcdee3),
    this.disabledColor = const Color(0xffdcc7ff),
    this.onDisabled = const Color(0xffffffff),
    this.colorWarning = const Color(0xffffc837),
    this.colorInfo = const Color(0xffff784b),
    this.colorSuccess = const Color(0xff3cd278),
    this.shadowColor = const Color(0xff1f1f1f),
    this.onInfo = const Color(0xffffffff),
    this.onWarning = const Color(0xffffffff),
    this.onSuccess = const Color(0xffffffff),
    this.colorError = const Color(0xfff0323c),
    this.onError = const Color(0xffffffff),
  });
}

class NavigationBarTheme {
  Color? backgroundColor, selectedItemIconColor, selectedItemTextColor, selectedItemColor, selectedOverlayColor, unselectedItemIconColor, unselectedItemTextColor, unselectedItemColor;
}
