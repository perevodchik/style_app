import 'package:style_app/model/City.dart';

class CitiesHolder {
  static List<City> cities = [];

  static City cityById(int cityId) {
    return cities.firstWhere((city) => city.id == cityId, orElse: null);
  }
}