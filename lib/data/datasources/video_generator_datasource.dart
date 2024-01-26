import "dart:async";
import "dart:convert";
import "package:d_id_task/data/network/remote_api.dart";
import "package:d_id_task/shared/constants/app_constants.dart";
import "package:dartz/dartz.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_webrtc/flutter_webrtc.dart";
import "../../shared/enums/enums.dart";
import "../failure/failure.dart";

abstract class BaseVideoGeneratorDatasource {
  Future<Either<Failure,void>> generateStreamingVideo(String promptText,
      String imageUrl, GenderType genderType);

  Future dispose(RTCVideoRenderer? videoRenderer);

  Future connect(String imageUrl, RTCVideoRenderer? videoRenderer,
      Function onVideoStatusUpdated);

  bool canGenerateVideo();

  Future onVideoStatusChange(bool videoIsPlaying, MediaStream? stream,
      RTCVideoRenderer? videoRenderer, Function updateIsGenerating);

  void onTrack(RTCTrackEvent? event, RTCVideoRenderer? videoRenderer,
      Function updateIsGenerating);

  void onIceCandidate(RTCIceCandidate iceCandidate, String streamId,
      String sessionId);

  Future<RTCSessionDescription> createStreamPeerConnection(RTCSessionDescription offer,
      List<dynamic> iceServers, String streamId, String sessionId,
      RTCVideoRenderer? videoRenderer, String imageUrl,
      Function updateIsGenerating);

  Future<Either<Failure,String>> generateIdleVideo(String imageUrl, GenderType genderType);
}

class VideoGeneratorDatasource implements BaseVideoGeneratorDatasource {

  final RemoteApi _remoteApi;

  VideoGeneratorDatasource(this._remoteApi);


  final url = AppConstants.baseStreamsApiUrl;
  final headers = {"Authorization" : "Basic ${dotenv.get("API_KEY")}",
    "Content-Type":"application/json"};
  final config = {"fluent" : true, "stitch" : true};
  RTCPeerConnection? peerConnection;
  String? currentStreamId;
  String? currentSessionId;
  Timer? statsInterval;
  int? lastBytesReceived;
  bool isVideoPlaying = false;

  @override
  Future<Either<Failure,void>> generateStreamingVideo(String promptText,
      String imageUrl, GenderType genderType) async {
    if(canGenerateVideo()) {
      final body = jsonEncode({
        "source_url": imageUrl,
        "script": getScript(promptText, genderType),
        "config" : config,
        "session_id": currentSessionId,
      });
      var getResponse = await _remoteApi.post("$url/$currentStreamId", headers, body);
      var result = jsonDecode(getResponse.body) as Map;
      debugPrint("VIDEO RESULT : $result");
      result.forEach((key, value) {debugPrint(key); debugPrint(value);});
      return const Right(null);
    }
    else {
      return const Left(Failure("Connection Error", -1));
    }
  }


  @override
  Future connect(String imageUrl, RTCVideoRenderer? videoRenderer,
      Function updateIsGenerating) async {
    if(peerConnection!=null) {
      if(peerConnection!.connectionState! == RTCPeerConnectionState.RTCPeerConnectionStateConnected){
        return;
      }
    }

    final response = await _remoteApi.post(url, headers, jsonEncode({"source_url": imageUrl}));

    debugPrint("FIRST RESPONSE : ${response.body}");

    final sessionResult = jsonDecode(response.body) as Map;
    debugPrint("REQUEST BODY : ${sessionResult.keys}");
    sessionResult.forEach((key, value) { debugPrint("$key : $value"); });

    currentSessionId = sessionResult["session_id"];
    currentStreamId = sessionResult["id"];

    final offerJson = sessionResult["offer"];
    final sessionClientAnswer = await createStreamPeerConnection(
        RTCSessionDescription(offerJson["sdp"], offerJson["type"]),
        sessionResult["ice_servers"], sessionResult["id"],
        sessionResult["session_id"], videoRenderer, imageUrl, updateIsGenerating);

    debugPrint("SessionClientAnswer");
    debugPrint(sessionClientAnswer.sdp);
    debugPrint(sessionClientAnswer.type);

    final requestBody = {
      'answer': sessionClientAnswer.toMap(),
      'session_id': sessionResult["session_id"]
    };

    final sdpResponse = await _remoteApi.post(
      "$url/${sessionResult["id"]}/sdp", headers, jsonEncode(requestBody),
    );

    videoRenderer = RTCVideoRenderer();
    await videoRenderer.initialize();

    debugPrint("SDP RESPONSE : ${sdpResponse.body}");
  }

  @override
  Future<RTCSessionDescription> createStreamPeerConnection(RTCSessionDescription offer,
      List<dynamic> iceServers, String streamId, String sessionId,
      RTCVideoRenderer? videoRenderer, String imageUrl,
      Function updateIsGenerating) async {

    if (peerConnection == null) {

      final config = {'iceServers': iceServers};

      peerConnection = await createPeerConnection(config);

      peerConnection!.onTrack = (RTCTrackEvent? event) {
        onTrack(event, videoRenderer, updateIsGenerating);
      };

      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        onIceCandidate(candidate, streamId, sessionId);
      };

      peerConnection!.onIceConnectionState = (RTCIceConnectionState state) async {
        if(state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {

        }
        else if(state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
            state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
        state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          await dispose(videoRenderer);
          await connect(imageUrl, videoRenderer, updateIsGenerating);
        }
      };

    }

    await peerConnection!.setRemoteDescription(offer);
    final sessionClientAnswer = await peerConnection!.createAnswer({});
    await peerConnection!.setLocalDescription(sessionClientAnswer);

    return sessionClientAnswer;
  }

  @override
  void onIceCandidate(RTCIceCandidate iceCandidate, String streamId,
      String sessionId) {

    if (iceCandidate.candidate != null && iceCandidate.sdpMid!=null && iceCandidate.sdpMLineIndex!=null) {
      String candidate = iceCandidate.candidate!;
      String sdpMid = iceCandidate.sdpMid!;
      int sdpMLineIndex = iceCandidate.sdpMLineIndex!;

      String apiUrl = '$url/$streamId/ice';


      Map<String, dynamic> requestBody = {
        'candidate': candidate, 'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex, 'session_id': sessionId,
      };

      _remoteApi.post(apiUrl, headers, jsonEncode(requestBody),
      );
    }
  }

  @override
  void onTrack(RTCTrackEvent? event, RTCVideoRenderer? videoRenderer,
      Function updateIsGenerating) async {
    if (event?.track == null || peerConnection==null) return;

     statsInterval?.cancel();  // Cancel any previous timer

     statsInterval = Timer.periodic(const Duration(milliseconds: 500), (_) async {
       if(peerConnection!=null) {
         var statsReports = await peerConnection?.getStats();
         if (statsReports != null) {
           for (var report in statsReports.where((report) => report.type
               == 'inbound-rtp' && report.values["mediaType"] == 'video')) {
             // print("STATS REPORT");
             // print(report.type);
             // report.values.keys.forEach((element) { print(element); });
             final reportBytesReceived = report.values["bytesReceived"];
             bool videoStatusChanged =
                 isVideoPlaying != (reportBytesReceived > (lastBytesReceived ?? 0));

             if (videoStatusChanged) {
               isVideoPlaying = reportBytesReceived> (lastBytesReceived ?? 0);
               if(event?.streams != null) {
                 await onVideoStatusChange(isVideoPlaying, event?.streams[0],
                     videoRenderer, updateIsGenerating);
               }
             }
             lastBytesReceived = reportBytesReceived;
           }
         }
       }
     });
  }


  @override
  Future dispose(RTCVideoRenderer? videoRenderer) async {
    if(peerConnection!=null) {
      peerConnection!.onTrack = (_) {};
      peerConnection!.onIceCandidate = (_) {};
      peerConnection!.onIceConnectionState = (_) {};
      await peerConnection?.close();
      await peerConnection?.dispose();
      peerConnection = null;
    }

    if(currentStreamId!=null && currentSessionId!=null) {
      await _remoteApi.delete("$url/$currentStreamId!", headers, jsonEncode({
        'session_id': currentSessionId!}));
    }

    if(videoRenderer!=null) {
      videoRenderer.srcObject?.getTracks().forEach((track) { track.stop(); });
      videoRenderer.srcObject = null;
      videoRenderer.dispose();
    }

    statsInterval?.cancel();
    currentStreamId = null;
    currentSessionId = null;
    lastBytesReceived = null;
    isVideoPlaying = false;
  }

  @override
  bool canGenerateVideo() {
    return peerConnection?.signalingState == RTCSignalingState.RTCSignalingStateStable &&
        peerConnection?.iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected;
  }

  @override
  Future onVideoStatusChange(bool videoIsPlaying, MediaStream? stream,
      RTCVideoRenderer? videoRenderer, Function updateIsGenerating) async {
    if (videoIsPlaying) {
      if(stream!=null) {
        debugPrint("LIVE STREAMING");
        updateIsGenerating(true, true);
        await Future.delayed(const Duration(milliseconds: 150), () async {
          await videoRenderer?.setSrcObject(stream: stream);
          videoRenderer?.onFirstFrameRendered!();
        });
      }
    }
    else {
      updateIsGenerating(false,false);
      debugPrint("IDLE");
      //playIdleVideo();
    }
  }

  @override
  Future<Either<Failure, String>> generateIdleVideo(String imageUrl, GenderType genderType) async {
    final body = jsonEncode({
      "source_url": imageUrl,
      "driver_url": "bank://lively/driver-06",
      "script": {
        "type": "text",
        "ssml": true,
        "input": "<break time=\"5000ms\"/><break time=\"5000ms\"/><break time=\"5000ms\"/>"
      },
      "config" : config,});

    const talksUrl = AppConstants.baseTalksApiUrl;
    final response = await _remoteApi.post(talksUrl, headers, body);
    if (response.statusCode.toString()[0] == "2") {
      final res = json.decode(response.body);
      final id = res["id"];
      var status = res["status"];

      while (status == "created" || status == "started") {
        final getResponse = await _remoteApi.get('$talksUrl/$id', headers);
        debugPrint(getResponse.body);
        final res = json.decode(getResponse.body);
        status = res["status"];
        debugPrint("NEW STATUS : $status");
        if (status == "done") {
          debugPrint("IDLE VIDEO RESULT: ${res["result_url"]}");
          return Right(res["result_url"]);
        } else {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
    return const Left(Failure("Check your connection", -1));
  }

  Map getScript(String promptText, GenderType genderType) => {
    "type": "text",
    "ssml": true,
    "input": promptText,
    "provider": {
      "type": "microsoft", "voice_config": {"style": "Cheerful"},
      "voice_id": genderType == GenderType.male
          ? AppConstants.maleVoiceId : AppConstants.femaleVoiceId,}
  };

}