
import 'package:d_id_task/shared/enums/enums.dart';

class AppConstants {

  static Map<GenderType, String> presenterGenderImgUrl = {
    GenderType.male:"https://img.freepik.com/free-photo/bohemian-man-with-his-arms-crossed_1368-3542.jpg?size=512&ext=jpg&uid=R133412872&ga=GA1.1.151527479.1697211504&semt=sph",
    GenderType.female: "https://img.freepik.com/free-vector/portrait-beautiful-girl-with-tiara-her-head_1196-849.jpg?size=512&t=st=1705550694~exp=1705551294~hmac=94ccda3403c5c65a3e7d88ab15b259968ae449cb0a48855120dc0837e884ad8c"
  };
  static Map<GenderType, String> presenterGenderHQImgUrl = {
    GenderType.male:"https://img.freepik.com/free-photo/bohemian-man-with-his-arms-crossed_1368-3542.jpg?size=1026&ext=jpg&uid=R133412872&ga=GA1.1.151527479.1697211504&semt=sph",
    GenderType.female: "https://img.freepik.com/free-vector/portrait-beautiful-girl-with-tiara-her-head_1196-849.jpg?size=1024&t=st=1705550694~exp=1705551294~hmac=94ccda3403c5c65a3e7d88ab15b259968ae449cb0a48855120dc0837e884ad8c"
  };
  static const baseStreamsApiUrl = "https://api.d-id.com/talks/streams";
  static const baseTalksApiUrl = "https://api.d-id.com/talks";
  static const defaultVideoSpeed = 0.8;
  static const maleVoiceId = "en-GB-RyanNeural";
  static const femaleVoiceId = "en-US-JennyNeural";

}