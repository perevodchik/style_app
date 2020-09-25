import 'package:flutter/cupertino.dart';
import 'package:style_app/model/Service.dart';

class SearchFilterProvider extends ChangeNotifier {
  List<int> _cities = [];
  List<Service> _services = [];
  bool _showWithHighRate = false;

  List<int> get cities => _cities;
  List<Service> get services => _services;
  bool get isShowWithHighRate => _showWithHighRate;

  set cities(List<int> val) {
    _cities.clear();
    _cities.addAll(val);
    notifyListeners();
  }

  set services(List<Service> val) {
    _services.clear();
    _services.addAll(val);
    notifyListeners();
  }

  void toggleCity(int val) {
    if(_cities.contains(val))
      _cities.remove(val);
    else
      _cities.add(val);
    notifyListeners();
  }

  void toggleService(Service val) {
    if(_services.contains(val))
      _services.remove(val);
    else
      _services.add(val);
    notifyListeners();
  }

  set isShowWithHighRate(bool val) {
    _showWithHighRate = val;
    notifyListeners();
  }
}