import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/detail_story.dart';
import 'package:storyapp/utils/result_state.dart';

class DetailStoryProvider extends ChangeNotifier {
  final ApiService apiService;
  final String id;

  DetailStoryProvider(this.apiService, this.id) {
    getDetailStory(id);
  }

  ResultState? _state;
  ResultState? get state => _state;

  Story _story = Story();
  Story get story => _story;

  String _message = "";
  String get message => _message;

  Future<dynamic> getDetailStory(String id) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final detailStoryResult = await apiService.getDetailStory(id);
      if (detailStoryResult.story != null) {
        _state = ResultState.hasData;
        _story = detailStoryResult.story ?? Story();

        _message = detailStoryResult.message ?? "Get detail story succes";
      } else {
        _state = ResultState.noData;

        _message = detailStoryResult.message ?? "Get detail story failed";
      }
    } on SocketException {
      _state = ResultState.error;
      _message = "Error: No internet connection";
    } catch (e) {
      _state = ResultState.error;
      _message = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
