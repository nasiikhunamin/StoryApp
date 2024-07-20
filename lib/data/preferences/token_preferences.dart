import 'package:shared_preferences/shared_preferences.dart';

class TokenPreferences {
  static const myToken = "token";
  static const state = "state";

  Future<bool> login() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(state, true);
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(state) ?? false;
  }

  Future<bool> isLogOut() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(state, false);
  }

  Future<bool> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(myToken, token);
  }

  Future<String> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(myToken) ?? '';
  }

  Future<bool> deleteToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(myToken, '');
  }
}
