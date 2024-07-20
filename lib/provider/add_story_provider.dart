import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/requests/add_story.dart';
import 'package:storyapp/utils/result_state.dart';

class AddStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  AddStoryProvider(this.apiService);

  ResultState? _state;
  ResultState? get state => _state;

  String _message = "";
  String get message => _message;
  File? _selectImage;
  File? get selectImage => _selectImage;
  Future<dynamic> addStory(AddStoryRequest storyRequest) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final detailStoryResult = await apiService.addStory(storyRequest);

      if (detailStoryResult.error == true) {
        _state = ResultState.error;
        _message = detailStoryResult.message ?? "Error uploading story";
      } else {
        _state = ResultState.hasData;

        _message = detailStoryResult.message ?? "Story uploaded";
      }
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

  void setSelectedImage(File? image) {
    _selectImage = image;
    notifyListeners();
  }
}
