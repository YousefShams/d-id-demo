import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {

  static void showErrorToast(String text) {
    Fluttertoast.showToast(msg: text, backgroundColor: Colors.red, textColor: Colors.white);
  }

}