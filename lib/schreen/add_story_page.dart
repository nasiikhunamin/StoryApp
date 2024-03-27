import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/models/requests/add_story.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/route/page_manager.dart';
import 'package:storyapp/utils/helper.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';

class AddStoryPage extends StatefulWidget {
  final VoidCallback onSuccessAddStory;
  const AddStoryPage({super.key, required this.onSuccessAddStory});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

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
      body: ChangeNotifierProvider<AddStoryProvider>.value(
        value: Provider.of<AddStoryProvider>(context),
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
            )),
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
