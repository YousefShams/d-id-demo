import 'package:flutter/material.dart';

import '../../../../shared/strings/app_strings.dart';

PreferredSizeWidget imageToVideoAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: const Text(AppStrings.appTitle,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
  );
}