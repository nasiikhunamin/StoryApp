import 'package:validators/validators.dart';

String? validateEmail(String? value) =>
    isEmail(value.toString()) ? "Invalid Email Format" : null;

String? validatePassword(String? value) =>
    (value!.length < 8) ? "Password must contains minimum 8 characters" : null;
