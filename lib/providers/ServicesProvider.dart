import 'package:flutter/cupertino.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/holders/CategoriesHolder.dart';

class ServicesProvider extends ChangeNotifier {
  List<Category> get map {
    return CategoriesHolder.categories;
  }

  set map(List<Category> val) {
    CategoriesHolder.categories = val;
    notifyListeners();
  }

  void setAtt(List<Category> val) {
    CategoriesHolder.categories.clear();
    CategoriesHolder.categories.addAll(val);
    notifyListeners();
  }
}