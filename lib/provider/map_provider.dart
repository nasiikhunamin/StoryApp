import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/utils/result_state.dart';

class MapProvider extends ChangeNotifier {
  final ApiService apiService;
  final LatLng location;

  MapProvider(this.apiService, this.location) {
    getLocation(location);
  }

  ResultState? _state;
  ResultState? get state => _state;

  String _addres = "-";
  String get address => _addres;

  String _message = "succes";
  String get message => _message;

  Future<dynamic> getLocation(LatLng location) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final locationResult = await apiService.getLocation(location);

      _state = ResultState.hasData;
      _addres = locationResult;
    } on SocketException {
      _state = ResultState.error;

      _message = "Error: No Internet Connection";
    } catch (e) {
      _state = ResultState.error;

      _message = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
