import 'package:flutter/material.dart';
import 'package:storyapp/data/models/detail_story.dart';

class StoryBullets extends StatelessWidget {
  final Story story;
  final VoidCallback onStoryClicked;
  const StoryBullets({
    super.key,
    required this.story,
    required this.onStoryClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: InkWell(
          onTap: onStoryClicked,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(story.photoUrl ?? ""),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  story.name ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
