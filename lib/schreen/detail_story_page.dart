import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/story.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/detail_story_provider.dart';
import 'package:storyapp/provider/map_provider.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';

class DetailStoryPage extends StatelessWidget {
  final String storyId;

  const DetailStoryPage({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.titleDetailStory)),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return ChangeNotifierProvider<DetailStoryProvider>(
      create: (context) => DetailStoryProvider(ApiService(), storyId),
      builder: (context, child) => _handleState(context),
    );
  }

  Widget _handleState(BuildContext context) {
    return Consumer<DetailStoryProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case ResultState.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ResultState.hasData:
            return _content(context, provider.story);
          case ResultState.error:
          case ResultState.noData:
            return Column(
              children: [
                Text(provider.message),
                CustomButton(
                  onPressed: () => provider.getDetailStory(storyId),
                  text: AppLocalizations.of(context)!.buttonReload,
                ),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }

  Widget _content(BuildContext context, Story story) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _detail(context, story),
        if (story.lat != null) _map(context, LatLng(story.lat!, story.lon!)),
      ],
    );
  }

  Widget _detail(BuildContext context, Story story) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.5,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (story.photoUrl != null) _image(context, story.photoUrl!),
            _information(context, story),
          ],
        ),
      ),
    );
  }

  Widget _image(BuildContext context, String url) {
    return Image.network(
      url,
      height: 200,
      width: double.maxFinite,
      fit: BoxFit.cover,
    );
  }

  Widget _information(BuildContext context, Story story) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            story.name ?? "-",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            story.description ?? "-",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _map(BuildContext context, LatLng location) {
    return Expanded(
      child: ChangeNotifierProvider(
        create: (context) => MapProvider(ApiService(), location),
        builder: (context, child) {
          return Consumer<MapProvider>(
            builder: (context, provider, _) {
              switch (provider.state) {
                case ResultState.loading:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ResultState.hasData:
                  return GoogleMap(
                    markers: {
                      Marker(
                        markerId: MarkerId(location.toString()),
                        position: location,
                        infoWindow: InfoWindow(
                          title: provider.address,
                          snippet: AppLocalizations.of(context)!.locationLatLng(
                              location.latitude, location.longitude),
                        ),
                      )
                    },
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 18,
                    ),
                  );
                case ResultState.error:
                case ResultState.noData:
                  return Column(
                    children: [
                      Text(provider.message),
                      CustomButton(
                        onPressed: () => provider.getLocation(location),
                        text: AppLocalizations.of(context)!.buttonReload,
                      ),
                    ],
                  );
                default:
                  return Container();
              }
            },
          );
        },
      ),
    );
  }
}
