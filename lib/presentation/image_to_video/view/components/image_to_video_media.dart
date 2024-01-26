import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_player/video_player.dart';
import '../../../../shared/styles/app_sizing_values.dart';
import '../../view_model/states.dart';

class ImageToVideoMedia extends StatelessWidget {

  final ImageToVideoState state;
  final bool isPlaying;
  final Function()? toggleGender;
  final VideoPlayerController? videoController;
  final RTCVideoRenderer? videoRenderer;
  final bool isVideoLoaded;

  const ImageToVideoMedia({Key? key, required this.state,
   required this.isPlaying, required this.videoController,
    this.toggleGender, this.videoRenderer, required this.isVideoLoaded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const p = AppValues.defaultPadding;
    final isZeroVideoSize = videoRenderer==null ? true : (videoRenderer!.videoWidth==0);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: p*2),
          child: Padding(
            padding: const EdgeInsets.all(p),
            child: ClipRRect(
              borderRadius: AppValues.defaultBorderRadius,
              child: Visibility(
                visible: state is! ImageToVideoLoadingState,
                replacement: const SizedBox(
                  height: AppValues.presenterWidgetHeight,
                  child: Center(child: CircularProgressIndicator(),),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  final videoWidth = constraints.maxWidth;
                  return AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isVideoLoaded && !isZeroVideoSize && isPlaying
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    firstChild: (videoController==null)
                        ? const SizedBox.shrink()
                        : Stack(
                      children: [
                        SizedBox(
                            width: videoWidth,
                            height: videoWidth *
                                (1/videoController!.value.aspectRatio),
                            child: VideoPlayer(videoController!)
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0.53, sigmaY: 0.53),
                          child: Container(color: Colors.transparent,
                            width: videoWidth,
                            height: videoWidth *
                                (1/videoController!.value.aspectRatio),),
                        )
                      ],
                    ),
                    secondChild: (!isVideoLoaded) ? const SizedBox.shrink()
                        : SizedBox(
                        width: (videoWidth),
                        height: (videoWidth) *
                            (1/videoRenderer!.value.aspectRatio),
                        child: RTCVideoView(videoRenderer!)
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top:AppValues.defaultPadding, right: AppValues.smallPadding),
              child: FloatingActionButton.small(
                onPressed: toggleGender,
                backgroundColor: Colors.teal.withOpacity(0.7),
                child: const Icon(Icons.switch_left_rounded, color: Colors.white),),
            ),
          ),
        )
      ],
    );
  }
}
