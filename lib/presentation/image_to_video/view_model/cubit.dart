import 'dart:async';
import 'package:d_id_task/main.dart';
import 'package:d_id_task/presentation/image_to_video/view/image_to_video_view.dart';
import 'package:d_id_task/presentation/image_to_video/view_model/states.dart';
import 'package:d_id_task/shared/constants/app_constants.dart';
import 'package:d_id_task/shared/enums/enums.dart';
import 'package:d_id_task/shared/strings/app_strings.dart';
import 'package:d_id_task/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_player/video_player.dart';
import '../../../repositories/video_generator_repo.dart';


class ImageToVideoCubit extends Cubit<ImageToVideoState> {
  final VideoGeneratorRepository _videoGeneratorRepo;
  ImageToVideoCubit(this._videoGeneratorRepo) : super(ImageToVideoInitialState());

  static ImageToVideoCubit get(BuildContext context) => BlocProvider.of(context);

  //VARIABLES
  RTCVideoRenderer? videoRenderer;
  final promptController = TextEditingController();
  String get promptText => promptController.text;
  GenderType genderType = GenderType.female;
  String idleImageUrl = AppConstants.presenterGenderImgUrl[GenderType.female]!;
  String streamingImageUrl = AppConstants.presenterGenderHQImgUrl[GenderType.female]!;
  bool isVideoLoaded = false;
  bool isGenerating = false;
  bool isPlaying = false;
  VideoPlayerController? videoController;
  bool idleVideoLoaded = false;

  //EVENTS
  Future init() async {
    emit(ImageToVideoLoadingState());
    await setConnectionVideoRenderer(streamingImageUrl);
  }

  Future generateVideo() async {
    if(promptText.isNotEmpty) {
      resetStreamVideo();
      isGenerating = true;
      emit(ImageToVideoSuccessState());
      final vidRemoteResult = await _videoGeneratorRepo.generateStreamingVideo(
          promptText, streamingImageUrl, genderType);
      vidRemoteResult.fold(
          (failure) async {
            Utils.showErrorToast("Connection Error");
            isGenerating = false;
            await _videoGeneratorRepo.dispose(videoRenderer);
            navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_)=> const ImageToVideoScreen()),
                    (route) => false);
          },
          (r) {
            debugPrint("SUCCESS");
          }
      );
    }
    else {
      Utils.showErrorToast(AppStrings.emptyPromptError);
    }
  }


  Future toggleGender() async {
    emit(ImageToVideoLoadingState());
    resetStreamVideo();
    resetIdleVideo();
    genderType = genderType==GenderType.male ? GenderType.female : GenderType.male;
    streamingImageUrl = AppConstants.presenterGenderHQImgUrl[genderType]!;
    idleImageUrl = AppConstants.presenterGenderImgUrl[genderType]!;
    await setConnectionVideoRenderer(streamingImageUrl);
  }


  void resetStreamVideo() {
    isGenerating = false;
  }

  void resetIdleVideo() {
    idleVideoLoaded = false;
    videoController = null;
  }

  Future setConnectionVideoRenderer(String imageUrl) async {
    await _videoGeneratorRepo.dispose(videoRenderer);
    isVideoLoaded = false;
    videoRenderer = RTCVideoRenderer();
    await videoRenderer?.initialize();
    videoRenderer?.onFirstFrameRendered = () {
      isVideoLoaded = true;
      emit(ImageToVideoSuccessState());
    };
    final result = await _videoGeneratorRepo.connect(imageUrl, videoRenderer,
        onVideoStatusUpdated);

    result.fold(
      (l) {
        setConnectionVideoRenderer(imageUrl);
      },
      (r) {
        runCanGenerateChecker();
      }
    );
  }

  void runCanGenerateChecker() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final canGenerateVideo = _videoGeneratorRepo.canGenerateVideo();
      if(canGenerateVideo) {
        timer.cancel();
        if(!idleVideoLoaded) generateIdleVideo();
      }
    });
  }

  Future generateIdleVideo() async {
    final result = await _videoGeneratorRepo.generateIdleVideo(idleImageUrl, genderType);
    result.fold((l) async {
      Utils.showErrorToast("Connection Error");
      await _videoGeneratorRepo.dispose(videoRenderer);
      navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_)=> const ImageToVideoScreen()),
              (route) => false);
    }, (url) {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          idleVideoLoaded = true;
          videoController?.play();
          videoController?.setLooping(true);
          emit(ImageToVideoSuccessState());
        });
    });
  }

  void onVideoStatusUpdated(bool isGenerating, bool isPlaying) {
    this.isGenerating = isGenerating;
    this.isPlaying = isPlaying;
    emit(ImageToVideoSuccessState());
  }
}