import 'package:flutter/cupertino.dart';
import 'package:style_app/model/City.dart';
import 'package:style_app/holders/CitiesHolder.dart';

class CitiesProvider extends ChangeNotifier {
  List<City> get cities => CitiesHolder.cities;
  set cities(List<City> val) {
    CitiesHolder.cities = val;
    notifyListeners();
  }

  City byId(int id) {
    return cities.firstWhere((city) => city.id == id, orElse: () => cities.first);
  }

  void add(City city) {
    CitiesHolder.cities.add(city);
  }

  void setAll(List<City> cities) {
    CitiesHolder.cities.clear();
    CitiesHolder.cities.addAll(cities);
    notifyListeners();
  }
}