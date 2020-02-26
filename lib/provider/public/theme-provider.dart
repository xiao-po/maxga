import 'package:flutter/material.dart';
import 'package:maxga/base/custom-ink-splash/custom-ink-splash.dart';
import 'package:maxga/provider/base/base-provider.dart';
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
      accentColor: isDarkMode ? Colors.teal : Colors.cyan,
      primaryColor: isDarkMode ? Colors.grey[800] : Colors.white,
      splashFactory: CustomInkSplash.splashFactory,
      cursorColor: isDarkMode ? Colors.teal : Colors.cyan,
      buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          colorScheme: ThemeData.light()
              .colorScheme
              .copyWith(primary: isDarkMode ? Colors.teal : Colors.cyan)),
      scaffoldBackgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
    );
  }

  Future<void> _changeBrightness(bool isDarkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DarkModeKey, isDarkTheme);
  }
}
