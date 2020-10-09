import 'dart:io';

import 'package:flutter/material.dart';
import 'package:style_app/utils/Constants.dart';

class Photo {
  String path;
  PhotoSource type;

  Photo(this.path, this.type);

  Widget getWidget() {
    if(path == null || path.isEmpty || !path.contains("/"))
      return Container();
    if(type == PhotoSource.FILE) {
      return Image.file(File(path));
    } else if(type == PhotoSource.NETWORK) {
      return Image.network("$url/images/$path");
    } else return Container();
  }

  @override
  String toString() {
    return "$path";
  }
}

enum PhotoSource {
  FILE,
  NETWORK
}
