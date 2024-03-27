import 'package:shared_preferences/shared_preferences.dart';

class TokenPreferences {
  static const token = "token";

  setToken(String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(token, value);
  }

  Future<String> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(token) ?? "";
  }
}
