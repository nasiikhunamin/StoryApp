import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/story.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/list_story_provider.dart';
import 'package:storyapp/provider/login_provider.dart';
import 'package:storyapp/route/page_manager.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';
import 'package:storyapp/widget/flag_icon.dart';
import 'package:storyapp/widget/snackbar_custom.dart';
import 'package:storyapp/widget/story_card.dart';

class ListStoryPage extends StatefulWidget {
  final VoidCallback onLogoutSucces;
  final Function(String?) onStoryClicked;
  final VoidCallback onAddStoryClicked;
  const ListStoryPage(
      {super.key,
      required this.onLogoutSucces,
      required this.onStoryClicked,
      required this.onAddStoryClicked});

  @override
  State<ListStoryPage> createState() => _ListStoryPageState();
}

class _ListStoryPageState extends State<ListStoryPage> {
  late ListStoryProvider _listStoryProvider;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final _scrollController = ScrollController();
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_infiniteScroll);
  }

  _infiniteScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _listStoryProvider.getStory();
    }
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (mounted) {
          showCustomSnackbar(
            context,
            AppLocalizations.of(context)!.permissionAllowLocation,
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showCustomSnackbar(
            context, AppLocalizations.of(context)!.permissionDeniedLocation);
      }
      openAppSettings();
      return;
    }

    widget.onAddStoryClicked();

    if (mounted) {
      final pageManager = context.read<PageManager>();
      final shouldRefresh = await pageManager.waitForResult();
      if (shouldRefresh) {
        _refreshKey.currentState?.show();
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleListStory),
        centerTitle: true,
        actions: [
          const FlagIcons(),
          IconButton(
            onPressed: _onLogOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ChangeNotifierProvider<ListStoryProvider>(
          create: (context) => ListStoryProvider(
            ApiService(),
          ),
          builder: (context, child) => _body(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: requestLocationPermission,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Consumer<ListStoryProvider>(
      builder: (context, provider, child) {
        _listStoryProvider = provider;
        return _listStoryState(provider);
      },
    );
  }

  Widget _listStoryState(ListStoryProvider provider) {
    switch (provider.state) {
      case ResultState.noData:
        hasMoreData = false;
        return _refreshPage(context, provider);
      case ResultState.loading:
      case ResultState.hasData:
        return _refreshPage(context, provider);
      case ResultState.error:
        return Column(
          children: [
            Text(provider.message),
            CustomButton(
              onPressed: () => provider.getStory(),
              text: AppLocalizations.of(context)!.buttonReload,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _refreshPage(BuildContext context, ListStoryProvider provider) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => provider.getStory(isRefresh: true),
      child: _listStory(
        context,
        provider.story,
      ),
    );
  }

  Widget _listStory(BuildContext context, List<Story> story) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      controller: _scrollController,
      itemCount: story.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < story.length) {
          return AnimationConfiguration.staggeredGrid(
            duration: const Duration(milliseconds: 300),
            position: index,
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: StoryCard(
                  story: story[index],
                  onStoryClicked: () => widget.onStoryClicked(story[index].id),
                ),
              ),
            ),
          );
        } else if (hasMoreData) {
          return const Center();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onLogOut() async {
    final provider = context.read<LoginProvider>();
    final result = await provider.logOut();
    if (result) widget.onLogoutSucces();
  }
}
