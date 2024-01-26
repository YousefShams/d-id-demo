import 'package:d_id_task/presentation/image_to_video/view/components/image_to_video_app_bar.dart';
import 'package:d_id_task/presentation/image_to_video/view/components/image_to_video_button.dart';
import 'package:d_id_task/presentation/image_to_video/view/components/image_to_video_field.dart';
import 'package:d_id_task/presentation/image_to_video/view/components/image_to_video_generating_indicator.dart';
import 'package:d_id_task/presentation/image_to_video/view/components/image_to_video_media.dart';
import 'package:d_id_task/presentation/image_to_video/view_model/cubit.dart';
import 'package:d_id_task/presentation/image_to_video/view_model/states.dart';
import 'package:d_id_task/shared/components/loading_screen.dart';
import 'package:d_id_task/shared/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ImageToVideoScreen extends StatelessWidget {
  const ImageToVideoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ImageToVideoCubit>()..init(),
      child: BlocBuilder<ImageToVideoCubit, ImageToVideoState>(
        builder: (context, state) {
          final cubit = ImageToVideoCubit.get(context);
          return (state is ImageToVideoLoadingState) ? const LoadingScreen() : Scaffold(
            appBar: imageToVideoAppBar(context),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageToVideoMedia(
                    state: state, videoRenderer: cubit.videoRenderer,
                    isPlaying: cubit.isPlaying, videoController: cubit.videoController,
                    toggleGender: cubit.toggleGender, isVideoLoaded: cubit.isVideoLoaded,
                  ),

                  ImageToVideoLoadingIndicator(
                    isGenerating: cubit.isGenerating,
                    isPlaying: cubit.isPlaying
                  ),

                  ImageToVideoField(promptController: cubit.promptController,
                  genderType: cubit.genderType,),

                  ImageToVideoButton(generateVideo: cubit.generateVideo,
                    isGenerating: cubit.isGenerating)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
