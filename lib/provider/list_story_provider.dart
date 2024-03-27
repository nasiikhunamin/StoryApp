import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/detail_story.dart';
import 'package:storyapp/utils/result_state.dart';

class ListStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  ListStoryProvider(this.apiService) {
    getStory();
  }

  ResultState? _state;
  ResultState? get state => _state;

  String _message = "";
  String get message => _message;

  final List<Story> _story = [];
  List<Story> get story => _story;

  Future<dynamic> getStory() async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final storyResult = await apiService.getAllStories();

      if (storyResult.listStory?.isNotEmpty == true) {
        _state = ResultState.hasData;
        _story.clear();
        _story.addAll(storyResult.listStory ?? List.empty());
        _message = storyResult.message ?? "Get Story Succes";
      } else {
        _state = ResultState.noData;

        _message = storyResult.message ?? "Get Story Failed";
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
}
