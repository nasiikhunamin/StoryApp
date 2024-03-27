import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/detail_story.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/detail_story_provider.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';

class DetailStoryPage extends StatelessWidget {
  final String storyId;
  const DetailStoryPage({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleDetailStory),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<DetailStoryProvider>(
        create: (context) => DetailStoryProvider(
          ApiService(),
          storyId,
        ),
        builder: (context, child) => _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Consumer<DetailStoryProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case ResultState.loading:
            return const Center(child: CircularProgressIndicator());
          case ResultState.hasData:
            return _detailStory(context, provider.story);
          case ResultState.error:
          case ResultState.noData:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(provider.message),
                const SizedBox(height: 15),
                CustomButton(
                  onPressed: () => provider.getDetailStory(storyId),
                  text: AppLocalizations.of(context)!.buttonReload,
                )
              ],
            );
          default:
            return Container();
        }
      },
    );
  }

  Widget _detailStory(BuildContext context, Story story) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              story.name ?? "-",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (story.photoUrl != null)
              Image.network(
                story.photoUrl!,
                height: 400,
              ),
            const SizedBox(height: 16, width: double.maxFinite),
            const SizedBox(height: 8),
            Text(
              story.description ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
