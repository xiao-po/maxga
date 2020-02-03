import 'package:flutter/material.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const DarkModeKey = 'darkMode';

class ThemeProvider extends BaseProvider {
  ThemeData _theme = ThemeData();

  ThemeData get theme => _theme;

  static ThemeProvider _instance;

  static ThemeProvider getInstance() {
    if (_instance == null) {
      _instance = ThemeProvider();
    }
    return _instance;
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _setBrightness(prefs.getBool(DarkModeKey) ?? false);
  }


  changeBrightness() {
    final isDarkMode = this.theme.brightness == Brightness.dark;
    this._setBrightness(!isDarkMode);
    notifyListeners();
  }
  setBrightness([bool isDarkMode = false]) {
    this._setBrightness(isDarkMode);
    notifyListeners();
  }

  _setBrightness(bool isDarkMode) {
    this._changeBrightness(isDarkMode);
    this._theme = ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        accentColor: isDarkMode ? Colors.teal : null,
    );
  }

  Future<void> _changeBrightness(bool isDarkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DarkModeKey, isDarkTheme);
  }
}
