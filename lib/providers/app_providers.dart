import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    final newTheme = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    if (_themeMode != newTheme) {
      _themeMode = newTheme;
      notifyListeners();
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  bool _enabled = false;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }
}
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  void toggleLocale() {
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}
