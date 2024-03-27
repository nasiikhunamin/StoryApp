import 'package:flutter/material.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale("id");
  Locale get local => _locale;

  void setLocal(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
