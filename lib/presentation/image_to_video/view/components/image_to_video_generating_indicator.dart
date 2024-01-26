import 'package:d_id_task/shared/styles/app_sizing_values.dart';
import 'package:flutter/material.dart';

class ImageToVideoLoadingIndicator extends StatelessWidget {
  final bool isGenerating;
  final bool isPlaying;
  const ImageToVideoLoadingIndicator({Key? key,
    required this.isGenerating, required this.isPlaying}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const p = AppValues.defaultPadding;
    return Padding(
      padding: const EdgeInsets.only(bottom: p, left: p, right: p),
      child: Visibility(visible:isGenerating && !isPlaying,
          child: const LinearProgressIndicator()),
    );
  }
}
