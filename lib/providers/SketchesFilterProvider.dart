import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:style_app/model/Sketch.dart';

class SketchesFilterProvider extends ChangeNotifier {
  List<String> _tags = [];
  RangeValues _values = RangeValues(1, 1);
  bool _isUseFilter = false;
  bool _isJustFavorite = false;

  List<String> get tags => _tags;
  set tags(List<String> val) {
    _tags.clear();
    _tags.addAll(val);
    notifyListeners();
  }

  RangeValues get values => _values;
  set values(RangeValues val) {
    _values = val;
    notifyListeners();
  }

  bool get isUseFilter => _isUseFilter;
  set isUseFilter(bool val) {
    _isUseFilter = val;
    notifyListeners();
  }

  bool get isJustFavorite => _isJustFavorite;
  set isJustFavorite(bool val) {
    _isJustFavorite = val;
    notifyListeners();
  }

  void addTag(String tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  bool filterByFavorite(Sketch sketch) {
    if(_isJustFavorite) {
      print("isFavorite? $sketch");
      return sketch.isFavorite;
    }
    return true;
  }

  bool filterByPrice(Sketch sketch) {
    return sketch.data.price >= _values.start && sketch.data.price <= _values.end;
  }

  bool filterByTags(Sketch sketch) {
    if(_tags.isNotEmpty) {
      if(_tags.length == 1 && _tags.isEmpty) {
        return true;
      } else {
        for(var tag in sketch.data.tags.split("#")) {
          if(_tags.contains(tag)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}