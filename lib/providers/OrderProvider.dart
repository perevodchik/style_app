import 'package:flutter/widgets.dart';
import 'package:style_app/holders/UserOrdersHolder.dart';
import 'package:style_app/model/Record.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderPreview> get previews => UserOrdersHolder.orderPreviews;
  set previews(List<OrderPreview> val) {
    UserOrdersHolder.orderPreviews = val;
    notifyListeners();
  }
  void addOrderPreview(OrderPreview val) {
    UserOrdersHolder.orderPreviews.insert(0, val);
    notifyListeners();
  }
  void setPreviews(List<OrderPreview> val) {
    UserOrdersHolder.orderPreviews.clear();
    UserOrdersHolder.orderPreviews.addAll(val);
    notifyListeners();
  }
}