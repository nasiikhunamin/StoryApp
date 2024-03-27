import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/requests/register_requests.dart';
import 'package:storyapp/utils/result_state.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService apiService;
  RegisterProvider(this.apiService);

  ResultState? _registerState;
  ResultState? get registerState => _registerState;

  String _registerMessage = "";
  String get registerMessage => _registerMessage;

  Future<dynamic> register(RegisterRequest registerRequest) async {
    try {
      _registerState = ResultState.loading;
      notifyListeners();
      final registerResult = await apiService.register(registerRequest);

      if (registerResult.error != true) {
        _registerState = ResultState.hasData;

        _registerMessage = registerResult.message ?? "Akun Berhasil Dibuat";
      } else {
        _registerState = ResultState.noData;
        _registerMessage = registerResult.message ?? "Gagal Membuat Akun";
      }
    } catch (e) {
      _registerState = ResultState.error;

      _registerMessage = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
