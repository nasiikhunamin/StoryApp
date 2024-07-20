import 'package:flutter/material.dart';

afterBuild(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback.call();
  });
}

enum FlavorType { free, paid }
