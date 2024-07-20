import 'package:flutter/material.dart';

class SplashSchreen extends StatelessWidget {
  const SplashSchreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/snapverse_logo.png"),
      ),
    );
  }
}
