import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:storyapp/data/models/detail_story.dart';
import 'package:storyapp/data/models/login.dart';
import 'package:storyapp/data/models/requests/add_story.dart';
import 'package:storyapp/data/models/requests/login_requests.dart';
import 'package:storyapp/data/models/requests/register_requests.dart';
import 'package:storyapp/data/models/server_response.dart';
import 'package:storyapp/data/models/stories.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';

class ApiService {
  static const String _baseUrl = "https://story-api.dicoding.dev/v1";

  Future<Login> login(LoginRequest loginRequest) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      body: loginRequest.toJson(),
    );
    var login = Login.fromJson(json.decode(response.body));

    if (response.statusCode >= 200) {
      return login;
    } else {
      throw Exception("${response.statusCode} - ${login.message}");
    }
  }

  Future<ServerResponse> register(RegisterRequest registerRequest) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/register"),
      body: registerRequest.toJson(),
    );

    var serverResponse = ServerResponse.fromJson(json.decode(response.body));

    if (response.statusCode == 201) {
      return serverResponse;
    } else {
      throw Exception("${response.statusCode} - ${serverResponse.message}");
    }
  }

  Future<Stories> getAllStories() async {
    var tokenPreferences = TokenPreferences();
    var token = await tokenPreferences.getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/stories"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    var stories = Stories.fromJson(json.decode(response.body));

    if (response.statusCode == 200) {
      return stories;
    } else {
      throw Exception("${response.statusCode} - ${stories.message}");
    }
  }

  Future<DetailStory> getDetailStory(String id) async {
    var tokenPreferences = TokenPreferences();
    var token = await tokenPreferences.getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/stories/$id"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    var detailStory = DetailStory.fromJson(json.decode(response.body));

    if (response.statusCode == 200) {
      return detailStory;
    } else {
      throw Exception("${response.statusCode} - ${detailStory.message}");
    }
  }

  Future<ServerResponse> addStory(AddStoryRequest addStory) async {
    var tokenPreferences = TokenPreferences();
    var token = await tokenPreferences.getToken();

    final request =
        http.MultipartRequest('POST', Uri.parse("$_baseUrl/stories"));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = addStory.description;
    request.files.add(http.MultipartFile(
      'photo',
      addStory.photo.readAsBytes().asStream(),
      addStory.photo.lengthSync(),
      filename: addStory.photo.path.split('/').last,
    ));
    if (addStory.lat != null) {
      request.fields['lat'] = addStory.lat.toString();
      request.fields['lon'] = addStory.lon.toString();
    }

    final response = await request.send().timeout(const Duration(seconds: 5));

    if (response.statusCode == 201) {
      String responseBody = await response.stream.bytesToString();
      return ServerResponse.fromJson(json.decode(responseBody));
    } else {
      throw Exception("${response.statusCode} - Error when upload story");
    }
  }
}