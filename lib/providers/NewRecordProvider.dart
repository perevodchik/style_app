import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/Time.dart';

class NewRecordProvider extends ChangeNotifier {
  String _name;
  String _description;
  String _position;
  double _price;
  final List<Service> _services = [];
  final List<File> _images = [];


  String get name => _name;
  String get description => _description;
  String get position => _position;
  double get price => _price;
  List<Service> get services => _services;
  List<File> get images => _images;

  set name(String val) {
    _name = val;
    notifyListeners();
  }
  set description(String val) {
    _description = val;
    notifyListeners();
  }
  set position(String val) {
    _position = val;
    notifyListeners();
  }
  set price(double val) {
    _price = val;
    notifyListeners();
  }
  set services(List<Service> val) {
    _services.clear();
    _services.addAll(val);
    notifyListeners();
  }
  set images(List<File> val) {
    _images.clear();
    _images.addAll(val);
    notifyListeners();
  }

  bool containsTatooService() {
    return false;
    for(var s in _services)
      if(s.id == 8)
        return true;
    return false;
  }

  void toggleService(Service service) {
    if(service.id == 8) {
      bool l = _services.contains(service);
      _services.clear();
      if(l)
        _services.add(service);
    }
    if(_services.contains(service))
      _services.remove(service);
    else
      _services.add(service);
    notifyListeners();
  }
  void addImage(File image) {
    _images.add(image);
    notifyListeners();
  }
}