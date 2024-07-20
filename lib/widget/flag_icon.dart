import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/provider/localization_provider.dart';
import 'package:storyapp/utils/localizations.dart';

class FlagIcons extends StatelessWidget {
  const FlagIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        icon: const Icon(Icons.flag_outlined, color: Colors.black),
        items: AppLocalizations.supportedLocales.map((Locale locale) {
          final flag = Localization.getFlag(locale.languageCode);
          return DropdownMenuItem(
            value: locale,
            child: Center(
              child: Text(
                flag,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            onTap: () {
              final provider =
                  Provider.of<LocalizationProvider>(context, listen: false);
              provider.setLocal(locale);
            },
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
