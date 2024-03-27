import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/models/detail_story.dart';
import 'package:storyapp/data/preferences/token_preferences.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/list_story_provider.dart';
import 'package:storyapp/route/page_manager.dart';
import 'package:storyapp/utils/helper.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';
import 'package:storyapp/widget/flag_icon.dart';
import 'package:storyapp/widget/story_bullets.dart';

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
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    afterBuild(() async {
      final pageManager = context.read<PageManager>();
      final refresh = await pageManager.waitForResult();

      if (refresh) {
        _refreshKey.currentState?.show();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        child: Consumer<ListStoryProvider>(
          builder: (context, provider, _) {
            return _listStoryState(provider);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddStoryClicked,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _refreshPage(BuildContext context, ListStoryProvider provider) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => provider.getStory(),
      child: _listStory(
        context,
        provider.story,
      ),
    );
  }

  Widget _listStory(BuildContext context, List<Story> story) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      crossAxisCount: 2,
      shrinkWrap: true,
      children: List.generate(
        story.length,
        (index) => StoryBullets(
          story: story[index],
          onStoryClicked: () => widget.onStoryClicked(
            story[index].id,
          ),
        ),
      ),
    );
  }

  Widget _listStoryState(ListStoryProvider provider) {
    switch (provider.state) {
      case ResultState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResultState.hasData:
        return _refreshPage(context, provider);
      case ResultState.error:
      case ResultState.noData:
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

  _onLogOut() {
    var tokenPreferences = TokenPreferences();
    tokenPreferences.setToken("");
    widget.onLogoutSucces();
  }
}
