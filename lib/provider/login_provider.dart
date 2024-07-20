import 'dart:io';
import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/requests/login_requests.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';
import 'package:storyapp/utils/result_state.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService apiService;
  final TokenPreferences tokenPref;

  LoginProvider(this.apiService, this.tokenPref);

  ResultState? _loginState;
  ResultState? get loginState => _loginState;

  String _loginMessage = "";
  String get loginMessage => _loginMessage;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<dynamic> login(LoginRequest request) async {
    _loginState = ResultState.loading;
    notifyListeners();
    try {
      final loginResult = await apiService.login(request);

      if (loginResult.error != true &&
          loginResult.loginResult!.token!.isNotEmpty) {
        await tokenPref.saveToken(loginResult.loginResult!.token!);
        notifyListeners();
        _isLoggedIn = await tokenPref.isLoggedIn();
        notifyListeners();
        _loginState = ResultState.hasData;
        notifyListeners();
        _loginMessage = 'Login ${loginResult.message}';
      } else {
        _loginState = ResultState.noData;

        _loginMessage = 'Login ${loginResult.message}';
      }
    } on SocketException {
      _loginState = ResultState.error;

      _loginMessage = "Error: No Internet Connection";
    } catch (e) {
      _loginState = ResultState.error;

      _loginMessage = "Error: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<bool> logOut() async {
    _loginState = ResultState.loading;
    notifyListeners();

    final logout = await tokenPref.isLogOut();

    if (logout) {
      await tokenPref.deleteToken();
      _isLoggedIn = await tokenPref.isLoggedIn();
      notifyListeners();
    }

    _loginState = _isLoggedIn ? ResultState.hasData : ResultState.error;

    notifyListeners();
    return !_isLoggedIn;
  }
}
