import 'dart:io';

import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../configs/constants.dart';
import '../../configs/styles.dart';
import '../../utils/shared_pref_manager.dart';

class AppThemeProvider extends ChangeNotifier {
  static bool kIsWeb = kIsWeb;
  static bool kIsWindow = Platform.isWindows;
  static bool kIsLinux = Platform.isLinux;
  static bool kIsMac = Platform.isMacOS;

  static bool kIsFullScreen = kIsLinux || kIsWeb || kIsWindow || kIsMac;

  bool _darkThemeMode = false;

  ThemeData? _lightTheme, _darkTheme;

  AppThemeProvider() {
    init();
  }

  init() async {
    bool? data =  await SharedPrefManager().getBool(SharePreferenceKeys.appThemeMode);
    if(data==null) {
      _darkThemeMode = false;
    }
    else {
      _darkThemeMode = data;
    }
    notifyListeners();
  }

  bool get darkThemeMode => _darkThemeMode;

  void setDarkThemeMode({bool isDarkThemeEnabled = false, bool isNotify = true}) {
    _darkThemeMode = isDarkThemeEnabled;
    SharedPrefManager().setBool(SharePreferenceKeys.appThemeMode, isDarkThemeEnabled);
    if(isNotify) notifyListeners();
  }

  void resetThemeMode({bool isNotify = true}) {
    setDarkThemeMode(isDarkThemeEnabled: false, isNotify: isNotify);
  }

  ThemeData getLightThemeData() {
    if(_lightTheme == null) {
      Styles styles = Styles();
      _lightTheme = AppTheme(styles: styles).getLightTheme();
    }
    return _lightTheme!;
  }

  ThemeData getDarkThemeData() {
    if(_darkTheme == null) {
      Styles styles = Styles();
      _darkTheme = AppTheme(styles: styles).getDarkTheme();
    }
    return _darkTheme!;
  }

  ThemeData getThemeData() {
    if(darkThemeMode) {
      return getDarkThemeData();
    }
    else {
      return getLightThemeData();
    }
  }
//endregion
}