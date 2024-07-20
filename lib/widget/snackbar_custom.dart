import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String message) {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    },
  );
}
