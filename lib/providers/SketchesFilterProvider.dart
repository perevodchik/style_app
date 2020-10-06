import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:style_app/model/Sketch.dart';

class SketchesFilterProvider extends ChangeNotifier {
  String _tags = "";
  int _min;
  int _max;
  RangeValues _values = RangeValues(1, 1);
  bool _isJustFavorite = false;

  int get min => _min;
  set min(int val) {
    _min = val;
    notifyListeners();
  }

  int get max => _max;
  set max(int val) {
    _max = val;
    notifyListeners();
  }

  String get tags => _tags;
  set tags(String val) {
    _tags = val;
    notifyListeners();
  }

  RangeValues get values => _values;
  set values(RangeValues val) {
    _values = val;
    notifyListeners();
  }

  bool get isJustFavorite => _isJustFavorite;
  set isJustFavorite(bool val) {
    _isJustFavorite = val;
    notifyListeners();
  }

}