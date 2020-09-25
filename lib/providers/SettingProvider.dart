import 'package:flutter/widgets.dart';

class SettingProvider extends ChangeNotifier {
  int _language = 0;
  bool _newOrder = true;
  bool _cancelOrder = true;
  bool _changeOrder = true;
  bool _isShowPhone = true;
  bool _isShowEmail = true;
  bool _isShowCity = true;

  int get language => _language;
  bool get newOrder => _newOrder;
  bool get cancelOrder => _cancelOrder;
  bool get changeOrder => _changeOrder;
  bool get isShowPhone => _isShowPhone;
  bool get isShowEmail => _isShowEmail;
  bool get isShowCity => _isShowCity;

  set language(int val) {
    _language = val;
    notifyListeners();
  }
  set newOrder(bool val) {
    _newOrder = val;
    notifyListeners();
  }
  set cancelOrder(bool val) {
    _cancelOrder = val;
    notifyListeners();
  }
  set changeOrder(bool val) {
    _changeOrder = val;
    notifyListeners();
  }

  set isShowPhone(bool val) {
    _isShowPhone = val;
    notifyListeners();
  }

  set isShowEmail(bool val) {
    _isShowEmail = val;
    notifyListeners();
  }

  set isShowCity(bool val) {
    _isShowCity = val;
    notifyListeners();
  }
}