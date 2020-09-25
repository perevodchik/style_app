import 'package:flutter/cupertino.dart';
import 'package:style_app/holders/OrdersHolder.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Service.dart';

class RecordProvider extends ChangeNotifier {
  bool _isFilterEnable = false;
  bool _isOnlyWithPrice = false;
  bool _isOnlyWithCity = false;
  List<int> _filterByCities = [];
  List<Service> _filterByServices = [];
  List<Order> _records = [];

  bool get isFilterEnable => _isFilterEnable;
  bool get isOnlyWithCity => _isOnlyWithCity;
  bool get isOnlyWithPrice => _isOnlyWithPrice;
  List<int> get filterByCities => _filterByCities;
  List<Service> get filterByServices => _filterByServices;
  List<Order> get records => _records;
  List<OrderAvailablePreview> get availableOrders => OrdersHolder.availables;

  set setAvailableOrders(List<OrderAvailablePreview> val) {
    print("0[$val]");
    OrdersHolder.availables.clear();
    OrdersHolder.availables.addAll(val);
    print("0[${OrdersHolder.availables}]");
    notifyListeners();
  }

  set addAvailableOrders(List<OrderAvailablePreview> val) {
    print("1[$val]");
    OrdersHolder.availables.addAll(val);
    print("1[${OrdersHolder.availables}]");
    notifyListeners();
  }

  set addAvailableOrder(OrderAvailablePreview val) {
    print("2[$val]");
    OrdersHolder.availables.add(val);
    print("2[${OrdersHolder.availables}]");
    notifyListeners();
  }

  set isFilterEnable(bool val) {
    _isFilterEnable = val;
    notifyListeners();
  }

  set isOnlyWithPrice(bool val) {
    _isOnlyWithPrice = val;
    notifyListeners();
  }

  set isOnlyWithCity(bool val) {
    _isOnlyWithCity = val;
    notifyListeners();
  }

  set filterByCities(List<int> cities) {
    _filterByCities = cities;
    notifyListeners();
  }

  set filterByServices(List<Service> services) {
    _filterByServices = services;
    notifyListeners();
  }

  void toggleCity(int city) {
    if(_filterByCities.contains(city))
      _filterByCities.remove(city);
    else _filterByCities.add(city);
    notifyListeners();
  }

  void toggleService(Service service) {
    if(_filterByServices.contains(service))
      _filterByServices.remove(service);
    else _filterByServices.add(service);
    notifyListeners();
  }

  List<Order> getRecordsByMaster(int masterId) {
    return records.where((r) => r.masterId == masterId).toList();
  }

  List<Order> getRecordsByClient(int clientId) {
    return records.where((r) => r.clientId == clientId).toList();
  }

  void update() {
    for(var r in records) {
      print("$r");
    }
    notifyListeners();
  }

  bool containsServices(List<Service> services) {
    if(filterByServices.isEmpty)
      return true;
    for(var s in filterByServices)
      if(!services.contains(s))
        return false;
    return true;
  }

  bool containsCities(int city) {
    if(filterByCities.isEmpty || city == null)
      return true;
    return filterByCities.contains(city);
  }

  bool isRecord({int masterId, int clientId}) {
    print("masterId $masterId, clientId $clientId");
    for(var r in _records) {
      print("$r");
      if(r.clientId == clientId &&
      r.masterId == masterId &&
      r.status == 2)
        return true;
    }
    _records.where((record) {
      print("++");
      return record.clientId == clientId &&
          record.masterId == masterId &&
          record.status == 2;
    });
    return false;
  }

  void addRecord(Order newRecord) {
    _records.insert(0, newRecord);
    notifyListeners();
  }

  void load(UserData user) async {
    records.clear();
    // records.addAll(await OrdersService.get().loadUserOrders(user));
    notifyListeners();
  }
}