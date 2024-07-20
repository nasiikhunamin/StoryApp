import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/story.dart';
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

  int page = 1;
  int size = 30;

  Future<dynamic> getStory({bool isRefresh = false}) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      if (isRefresh) {
        page = 1;
        _story.clear();
      }

      final storyResult = await apiService.getAllStories(page, size);

      if (storyResult.listStory?.isNotEmpty == true) {
        _state = ResultState.hasData;
        _story.addAll(storyResult.listStory!);
        _message = storyResult.message ?? "Get story succes";
        page++;
      } else {
        _state = ResultState.noData;
        _message = storyResult.message ?? "Get story failed";
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
