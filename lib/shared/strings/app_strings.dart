
import 'package:d_id_task/shared/enums/enums.dart';

class AppStrings {
  static const appTitle = "D-ID Streaming Demo";
  static String promptFieldHintText(GenderType gender) => "What do you want ${gender==GenderType.male ? "him" : "her"} to say?";
  static const generateButtonText = "Generate";
  static const emptyPromptError = "Please enter some text before generating";
  static const loadingCoach = "Connecting to your coach, please wait..";
}