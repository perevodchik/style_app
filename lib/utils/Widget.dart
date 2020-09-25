import 'package:flutter/cupertino.dart';

extension CustomDate on DateTime {

  String getTime() => "${this.hour < 10 ? "0${this.hour}" : this.hour}:${this.minute < 10 ? "0${this.minute}" : this.minute}";
  String getDate() => "${this.day < 10 ? "0${this.day}" : this.day}.${this.month < 10 ? "0${this.month}" : this.month}.${this.year}";

  String getFullDate() => "${this.getTime()} ${this.getDate()}";

}

extension CustomWidget on Widget {
  Widget scroll() => SingleChildScrollView(
    child: this
  );

  Widget background(Color color) => Container(
    color: color,
    child: this,
  );

  Widget sizeW(double width, double height) => SizedBox(
    height: height,
    width: width,
    child: this,
  );

  Widget paddingW({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this
      );

  Widget paddingAll(double padding) =>
      Padding(
          padding: EdgeInsets.all(padding),
          child: this
      );

  Widget marginAll(double padding) =>
      Container(
          margin: EdgeInsets.all(padding),
          child: this
      );

  Widget marginW({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      Container(
          margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
          child: this
      );

  Widget positionW(double left, double top, double right, double bottom) => Positioned(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    child: this,
  );

  Widget safe() => SafeArea(
    bottom: false,
    child: this
  );

  Widget onClick(Function() click) =>
    GestureDetector(
      onTap: click,
      child: this,
    );

  Widget center() => Center(child: this);

  Widget visibility(bool isVisible) => Visibility(
    visible: isVisible,
    child: this,
  );

}