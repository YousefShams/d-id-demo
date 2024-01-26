import 'package:d_id_task/shared/enums/enums.dart';
import 'package:flutter/material.dart';

import '../../../../shared/strings/app_strings.dart';
import '../../../../shared/styles/app_sizing_values.dart';

class ImageToVideoField extends StatelessWidget {
  final TextEditingController promptController;
  final GenderType genderType;

  const ImageToVideoField({Key? key, required this.promptController,
    required this.genderType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppValues.defaultVerticalSpace),
      child: Padding(
        padding: const EdgeInsets.all(AppValues.defaultPadding),
        child: TextFormField(
          controller: promptController,
          decoration: InputDecoration(
              labelText: AppStrings.promptFieldHintText(genderType)
          ),
        ),
      ),
    );
  }
}
