import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class CommonUtils {
  /*load image from base64*/
  static Image imageFromBase64String(String base64) {
    if (base64 != null) { 
      return Image.memory(base64Decode(base64),
          fit: BoxFit.cover, gaplessPlayback: true);
    }
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
