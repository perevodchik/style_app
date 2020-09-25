import 'package:flutter/widgets.dart';

class Global {
  static MediaQueryData data;
  static double width;
  static double height;
  static double pr;
  static double blockX;
  static double blockY;

  static build(MediaQueryData _ctx) {
    data = _ctx;
    width = data.size.width;
    height= data.size.height;
    pr = data.devicePixelRatio;
    blockX = width / 100;
    blockY = height / 100;
    print(toStr());
  }


  @override
  String toString() {
    return 'Global{width -> $width; height -> $height; po -> $pr; blockX -> $blockX; blockY -> $blockY}';
  }

  static String toStr() {
    return 'Global{width -> ${width * pr}; height -> ${height * pr}; po -> $pr; blockX -> $blockX; blockY -> $blockY}';
  }

}