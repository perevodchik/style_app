import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformLoadingCircleIndicator {
  Widget build(BuildContext context) {
    if(Platform.isIOS) {
      return CupertinoActivityIndicator();
    } else if(Platform.isAndroid) {
      return CircularProgressIndicator();
    } else return Container();
  }
}