import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:style_app/utils/Global.dart';

const String url = "http://10.0.2.2:8089";

final double margin5 = Global.blockX * 5;
const BorderRadius defaultItemBorderRadius = BorderRadius.all(Radius.circular(10));
const BorderRadius defaultModalBorderRadius = BorderRadius.vertical(top: Radius.circular(10));
const BorderRadius defaultCircleBorderRadius = BorderRadius.all(Radius.circular(50));
const BorderRadius defaultModalRadius = BorderRadius.vertical(top: Radius.circular(10));
final Color defaultItemColor = Colors.grey.withOpacity(0.05);
final Color defaultColorAccent = Colors.blueAccent;
BoxShadow generateShadow({Color color = Colors.grey, double opacity = 0.3}) => BoxShadow(
      color: color.withOpacity(opacity),
      spreadRadius: 2,
      blurRadius: 15,
      offset: Offset(0, 1)
  );
