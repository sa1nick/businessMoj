import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Global {

showToast({required String message}) {
  return Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black.withOpacity(0.8),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}






}


Future<File?> getLostData(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? media = await picker.pickImage(
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 100, source: source,
    );
    if (media != null) {

      return File(media.path);
    }
  } catch (e) {
    return null;
  }
}
