import 'package:d_id_task/shared/strings/app_strings.dart';
import 'package:d_id_task/shared/styles/app_sizing_values.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppValues.defaultPadding),
          Text(AppStrings.loadingCoach, textAlign: TextAlign.center),
          SizedBox(width: double.maxFinite)
        ],
      ),
    );
  }
}
