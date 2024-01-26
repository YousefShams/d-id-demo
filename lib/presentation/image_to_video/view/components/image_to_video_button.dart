import 'package:flutter/material.dart';

import '../../../../shared/strings/app_strings.dart';
import '../../../../shared/styles/app_sizing_values.dart';

class ImageToVideoButton extends StatelessWidget {
  final Function()? generateVideo;
  final bool isGenerating;

  const ImageToVideoButton({Key? key, required this.generateVideo,
    required this.isGenerating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isGenerating ? Colors.grey : Colors.teal;
    return OutlinedButton(
        onPressed: !isGenerating ? generateVideo : null,
        style: ButtonStyle(side: MaterialStatePropertyAll(
            BorderSide(color: color.withOpacity(0.5), width: 1.5)
        )),
        child: Padding(
          padding: const EdgeInsets.all(AppValues.smallPadding),
          child: Text(AppStrings.generateButtonText, style: TextStyle(
           fontSize: 19, fontWeight: FontWeight.bold, color: color)),
        )
    );
  }
}
