import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class ServicesRepository {

  static ServicesRepository _instance;

  static ServicesRepository get() {
    if(_instance == null)
      _instance = ServicesRepository();
    return _instance;
  }

  Future<List<Category>> getAllCategoriesAndServices(ServicesProvider provider) async{
    var map = <Category> [];
    var r = await http.get("http://10.0.2.2:8089/categories/all", headers: HeadersUtil.getHeaders());
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body.toString());
      for(var c in b) {
        var category = Category.fromJson(c);
        map.add(category);
      }
    }
    provider.setAtt(map);
    return map;
  }

  Future<List<Category>> getMasterServices(ProfileProvider provider) async {
    var data = <Category> [];
    var r = await http.get("http://10.0.2.2:8089/masters/services/${provider.id}",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var c in b) {
        var category = Category.fromJson(c);
        print("category ${category.toString()}");
        data.add(category);
      }
    }
    return data;
  }

  Future<ServiceWrapper> createMasterService(ProfileProvider provider, ServiceWrapper wrapper) async {
    var body = jsonEncode({
      "id": wrapper.id,
      "masterId": provider.id,
      "serviceId": wrapper.serviceId,
      "price": wrapper.price,
      "time": wrapper.time,
      "description": wrapper.description
    });
    var r = await http.post("http://10.0.2.2:8089/masters/services/create",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200 ? wrapper : null;
  }

  Future<bool> deleteMasterService(ProfileProvider provider, ServiceWrapper wrapper) async {
    var body = jsonEncode({
      "id": wrapper.id,
      "masterId": provider.id,
      "serviceId": wrapper.serviceId,
      "price": wrapper.price,
      "time": wrapper.time,
      "description": wrapper.description
    });
    var r = await http.post("http://10.0.2.2:8089/masters/services/delete",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }

  Future<bool> updateMasterService(ProfileProvider provider, ServiceWrapper wrapper, String text, int price, int time) async {
    var body = jsonEncode({
      "id": wrapper.id,
      "masterId": provider.id,
      "serviceId": wrapper.serviceId,
      "price": price,
      "time": time,
      "description": text
    });
    print(body);
    var r = await http.post("http://10.0.2.2:8089/masters/services/update",
      headers: HeadersUtil.getAuthorizedHeaders(provider.token),
      body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }
}