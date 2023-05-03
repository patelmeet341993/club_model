import 'dart:io';

import 'package:flutter/material.dart';

import '../../configs/constants.dart';
import '../../utils/shared_pref_manager.dart';

class AppThemeProvider extends ChangeNotifier {
  static bool kIsWeb = kIsWeb;
  static bool kIsWindow = Platform.isWindows;
  static bool kIsLinux = Platform.isLinux;
  static bool kIsMac = Platform.isMacOS;

  static bool kIsFullScreen = kIsLinux || kIsWeb || kIsWindow || kIsMac;

  int _themeMode = 1;

  AppThemeProvider() {
    init();
  }

  init() async {
    int? data =  await SharedPrefManager().getInt(SharePreferenceKeys.appThemeMode);
    if(data==null) {
      _themeMode = 1;
    }
    else {
      _themeMode = data;
    }
    notifyListeners();
  }

  int get themeMode => _themeMode;

  Future<void> updateTheme(int themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    SharedPrefManager().setInt("themeMode", themeMode);
  }
}