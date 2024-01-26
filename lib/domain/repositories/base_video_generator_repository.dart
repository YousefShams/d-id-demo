import 'package:d_id_task/data/failure/failure.dart';
import 'package:d_id_task/shared/enums/enums.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class BaseVideoGeneratorRepository {
  Future<Either<Failure,void>> generateStreamingVideo(String promptText,
      String imageUrl, GenderType genderType);
  Future<Either<Failure,void>> connect(String imageUrl, RTCVideoRenderer? videoRenderer,
      Function onVideoStatusUpdated);
  bool canGenerateVideo();
  Future dispose(RTCVideoRenderer? videoRenderer);
  Future<Either<Failure,String>> generateIdleVideo(String imageUrl, GenderType genderType);
}