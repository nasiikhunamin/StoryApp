import 'package:flutter/material.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';
import 'package:storyapp/schreen/add_location_page.dart';
import 'package:storyapp/schreen/add_story_page.dart';
import 'package:storyapp/schreen/detail_story_page.dart';
import 'package:storyapp/schreen/list_story_page.dart';
import 'package:storyapp/schreen/login_page.dart';
import 'package:storyapp/schreen/register_page.dart';
import 'package:storyapp/schreen/splash_schreen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;

  MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    var tokenPreferences = TokenPreferences();

    isLoggedIn = (await tokenPreferences.getToken()).isNotEmpty;
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? storyId;
  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool isAddStory = false;
  bool isAddLocation = false;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        isRegister = false;
        if (!isAddLocation) {
          isAddStory = false;
        }
        isAddLocation = false;
        storyId = null;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) {
    throw UnimplementedError();
  }

  List<Page> get _splashStack => [
        const MaterialPage(
          key: ValueKey("SplashStack"),
          child: SplashSchreen(),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginPage(
            onLoginSucces: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegisterClicked: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            child: RegisterPage(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("ListStoryPage"),
          child: ListStoryPage(
            onLogoutSucces: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onStoryClicked: (String? id) {
              storyId = id;
              notifyListeners();
            },
            onAddStoryClicked: () {
              isAddStory = true;
              notifyListeners();
            },
          ),
        ),
        if (storyId != null)
          MaterialPage(
            key: const ValueKey("DetailStoryPage"),
            child: DetailStoryPage(
              storyId: storyId!,
            ),
          ),
        if (isAddStory)
          MaterialPage(
            child: AddStoryPage(
              onSuccessAddStory: () {
                isAddStory = false;
                notifyListeners();
              },
              onAddLocation: () {
                isAddLocation = true;
                notifyListeners();
              },
            ),
          ),
        if (isAddLocation)
          MaterialPage(child: AddLocationPage(
            onSuccesStoryAdded: () {
              isAddLocation = false;
              notifyListeners();
            },
          ))
      ];
}
