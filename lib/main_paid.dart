import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';
import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/provider/localization_provider.dart';
import 'package:storyapp/provider/login_provider.dart';
import 'package:storyapp/provider/register_provider.dart';
import 'package:storyapp/route/location_page_manager.dart';
import 'package:storyapp/route/page_manager.dart';
import 'package:storyapp/route/router_delegate.dart';
import 'package:storyapp/utils/flavor_config.dart';
import 'package:storyapp/utils/flavor_value.dart';
import 'package:storyapp/utils/helper.dart';
import 'export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  _initFlavor();
  runApp(const MyApp());
}

_initFlavor() {
  FlavorConfig(
      flavor: FlavorType.paid,
      value: const FlavorValue(
        isLocationEnable: true,
      ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate _myRouterDelegate;

  @override
  void initState() {
    super.initState();
    _myRouterDelegate = MyRouterDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PageManager>(
          create: (context) => PageManager(),
        ),
        ChangeNotifierProvider<LoginProvider>(
          create: (context) => LoginProvider(ApiService(), TokenPreferences()),
        ),
        ChangeNotifierProvider<RegisterProvider>(
          create: (context) => RegisterProvider(
            ApiService(),
          ),
        ),
        ChangeNotifierProvider<AddStoryProvider>(
          create: (context) => AddStoryProvider(
            ApiService(),
          ),
        ),
        ChangeNotifierProvider<LocalizationProvider>(
          create: (context) => LocalizationProvider(),
        ),
        ChangeNotifierProvider<LocationPageManager>(
          create: (context) => LocationPageManager(),
        )
      ],
      builder: (context, child) {
        final localizationProvider = Provider.of<LocalizationProvider>(context);

        return MaterialApp(
          title: "SnapVerse",
          home: Router(
            routerDelegate: _myRouterDelegate,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localizationProvider.local,
        );
      },
    );
  }
}
