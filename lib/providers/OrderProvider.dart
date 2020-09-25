import 'package:flutter/widgets.dart';
import 'package:style_app/holders/UserOrdersHolder.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/Time.dart';
import 'package:style_app/service/OrdersService.dart';

class OrderProvider extends ChangeNotifier {
  List<Service> _services = [];

  List<Service> get services => _services;

  List<OrderPreview> get previews => UserOrdersHolder.orderPreviews;

  set services(List<Service> value) {
    _services = value;
    notifyListeners();
  }

  void addPreviews(List<OrderPreview> val) {
    UserOrdersHolder.orderPreviews.addAll(val);
    notifyListeners();
  }

  set previews(List<OrderPreview> val) {
    UserOrdersHolder.orderPreviews.clear();
    UserOrdersHolder.orderPreviews.addAll(val);
    notifyListeners();
  }


  void toggle(Service service) {
    if(services.contains(service))
      services.remove(service);
    else
      services.add(service);
    notifyListeners();
  }
}