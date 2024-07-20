import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_services.dart';
import 'package:storyapp/data/models/requests/add_story.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/route/location_page_manager.dart';
import 'package:storyapp/route/page_manager.dart';
import 'package:storyapp/utils/flavor_config.dart';
import 'package:storyapp/utils/helper.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';

class AddStoryPage extends StatefulWidget {
  final VoidCallback onSuccessAddStory;
  final VoidCallback onAddLocation;
  const AddStoryPage(
      {super.key,
      required this.onSuccessAddStory,
      required this.onAddLocation});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  LatLng? _selectLocation;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createStory),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AddStoryProvider>(
        create: (context) => AddStoryProvider(
          ApiService(),
        ),
        child: _addStory(context),
      ),
    );
  }

  Widget _addStory(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Consumer<AddStoryProvider>(
                builder: (context, provider, child) {
                  return Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _pickImage(provider),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (provider.selectImage != null)
                            Image.file(
                              provider.selectImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          Text(AppLocalizations.of(context)!.selectImage)
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fieldDescription,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              if (FlavorConfig.instance.value.isLocationEnable) ...[
                CustomButton(
                  text: (_selectLocation != null)
                      ? AppLocalizations.of(context)!.locationLatLng(
                          _selectLocation!.latitude, _selectLocation!.longitude)
                      : AppLocalizations.of(context)!.addLocationButton,
                  onPressed: () async {
                    widget.onAddLocation();
                    final locationManager = context.read<LocationPageManager>();
                    var result = await locationManager.waitForResult();
                    setState(() {
                      _selectLocation = result;
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              Consumer<AddStoryProvider>(
                builder: (context, provider, child) {
                  _handleAddStoryState(provider);
                  return CustomButton(
                      isLoading: provider.state == ResultState.loading,
                      onPressed: () => _upLoadStory(provider),
                      text: AppLocalizations.of(context)!.buttonUpload);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _handleAddStoryState(AddStoryProvider provider) {
    switch (provider.state) {
      case ResultState.hasData:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(provider.message)));
        });
        afterBuild(() {
          context.read<PageManager>().returnData(true);
          widget.onSuccessAddStory();
        });
        break;
      case ResultState.error:
      case ResultState.noData:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(provider.message)));
        });
        break;
      default:
        break;
    }
  }

  _upLoadStory(AddStoryProvider provider) {
    if (_formKey.currentState?.validate() == true &&
        provider.selectImage != null) {
      AddStoryRequest request = AddStoryRequest(
        description: _descriptionController.text,
        photo: provider.selectImage!,
        lat: _selectLocation?.latitude,
        lon: _selectLocation?.longitude,
      );
      provider.addStory(request);
    }
  }

  Future<void> _pickImage(AddStoryProvider provider) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      provider.setSelectedImage(File(pickedImage.path));
    }
  }
}
