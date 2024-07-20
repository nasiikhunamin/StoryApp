import 'dart:async';

import 'package:flutter/material.dart';

class PageManager extends ChangeNotifier {
  late Completer<bool> _completer;

  Future<bool> waitForResult() async {
    _completer = Completer<bool>();
    return _completer.future;
  }

  void returnData(bool value) {
    _completer.complete(value);
  }
}
