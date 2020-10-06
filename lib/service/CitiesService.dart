import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/model/City.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class CitiesService {

  static CitiesService _instance;

  static CitiesService get() {
    if(_instance == null)
      _instance = CitiesService();
    return _instance;
  }

  Future<List<City>> getCities(CitiesProvider provider) async {
    var cities = <City> [];
    var r = await http.get("$url/cities/all",
        headers: HeadersUtil.getHeaders());
    print("[${r.statusCode}] [${r.body}]");
    if (r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      print(b);
      for (var c in b) {
        var city = City(
            c["id"],
            c["name"]
        );
        cities.add(city);
      }
      provider.setAll(cities);
    }
    return cities;
  }

}