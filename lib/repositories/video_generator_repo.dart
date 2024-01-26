import 'dart:async';

import 'package:d_id_task/data/datasources/video_generator_datasource.dart';
import 'package:d_id_task/data/failure/failure.dart';
import 'package:d_id_task/domain/repositories/base_video_generator_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../shared/enums/enums.dart';

class VideoGeneratorRepository implements BaseVideoGeneratorRepository {
  final BaseVideoGeneratorDatasource _videoGeneratorDS;

  const VideoGeneratorRepository(this._videoGeneratorDS);

  @override
  Future<Either<Failure, void>> generateStreamingVideo(String promptText,
      String imageUrl, GenderType genderType) async {
    try {
      final result = await _videoGeneratorDS.generateStreamingVideo(promptText,
          imageUrl, genderType);
      return result;
    }
    catch(e) {
      debugPrint(e.toString());
      return const Left(Failure("Unknown Error Occurred", -1));
    }
  }

  @override
  Future<Either<Failure,void>> connect(String imageUrl, RTCVideoRenderer? videoRenderer,
      Function onVideoStatusUpdated) async {
    try{
      await _videoGeneratorDS.connect(imageUrl,videoRenderer, onVideoStatusUpdated)
          .timeout(const Duration(seconds: 30), onTimeout: () { throw TimeoutException("Connection Timeout"); });
      return const Right(null);
    }
    catch(e) {
      debugPrint(e.toString());
      return Left(Failure(e.toString(), -1));
    }
  }

  @override
  bool canGenerateVideo() {
    try {
      return _videoGeneratorDS.canGenerateVideo();
    }
    catch(e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future dispose(RTCVideoRenderer? videoRenderer) async {
    try {
      await _videoGeneratorDS.dispose(videoRenderer);
    }
    catch(_){}
  }

  @override
  Future<Either<Failure, String>> generateIdleVideo(String imageUrl, GenderType genderType) async {
    try {
      return await _videoGeneratorDS.generateIdleVideo(imageUrl, genderType);
    }
    catch(e) {
      return Left(Failure(e.toString(), -1));
    }
  }

}