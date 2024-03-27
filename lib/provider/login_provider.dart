import 'dart:io';
import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/requests/login_requests.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';
import 'package:storyapp/utils/result_state.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService apiService;
  final TokenPreferences tokenPreferences;

  LoginProvider(this.apiService, this.tokenPreferences);

  ResultState? _loginState;
  ResultState? get loginState => _loginState;

  String _loginMessage = "";
  String get loginMessage => _loginMessage;

  Future<dynamic> login(LoginRequest request) async {
    try {
      _loginState = ResultState.loading;
      notifyListeners();

      final loginResult = await apiService.login(request);

      if (loginResult.error != true) {
        _loginState = ResultState.hasData;
        tokenPreferences.setToken(loginResult.loginResult?.token ?? "");
        _loginMessage = loginResult.message ?? "Login Succes";
      } else {
        _loginState = ResultState.noData;
        _loginMessage = loginResult.message ?? "Login Failed";
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
}
