import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/model/MasterData.dart';

import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Sentence.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/HeadersUtil.dart';
import 'package:style_app/utils/TempData.dart';

class OrdersService {
  static OrdersService _instance;

  static OrdersService get() {
    if(_instance == null)
      _instance = OrdersService();
    return _instance;
  }

  void createOrder(String token, Order order) async {
    var body = jsonEncode({
      "masterId": order.masterId,
      "price": order.price == null ? 0 : order.price,
      "name": order.name,
      "description": order.description,
      "services": order.services.map((s) => s.id).toList(),
      "sketchData": order.sketch != null ? order.sketch.toJson() : null,
      "isPrivate": order.masterId != null,
      "status": order.masterId != null ? 3 : 0
    });
    print("body in [\n$body\n]");
    var r = await http.post(
      "http://10.0.2.2:8089/orders/create",
      body: body,
      headers: HeadersUtil.getAuthorizedHeaders(TempData.user.token)
    );
    print("[code ${r.statusCode}]\n[body ${r.body}]\n[${r.headers}]");
  }

  Future<List<OrderAvailablePreview>> loadAvailableOrders(ProfileProvider provider, int page, int limit) async {
    var orders = <OrderAvailablePreview> [];

    var r = await http.get("http://10.0.2.2:8089/orders/all?page=$page&limit=$limit",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var a in b)
        orders.add(OrderAvailablePreview.fromJson(a));
    }
    return orders;
  }

  Future<List<OrderPreview>> loadUserOrders(ProfileProvider profile) async {
    var orders = <OrderPreview> [];
    var r = await http.get(
        "http://10.0.2.2:8089/orders/user",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token)
    );
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);

      for(var e in b) {
        var order = OrderPreview(
            e["id"],
            e["price"],
            e["status"],
            e["sentencesCount"] ?? 0,
            e["name"],
        );
        orders.add(order);
      }

    }
    print("[code ${r.statusCode}] [body ${r.body}]");
    return orders;
  }

  Future<OrderFull> orderById(ProfileProvider provider, int orderId) async {
    var r = await http.get("http://10.0.2.2:8089/orders/$orderId",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      var clientData = UserShort(
        b["client"]["id"],
        b["client"]["name"],
        b["client"]["surname"],
        b["client"]["avatar"]
      );
      UserShort masterData;
      SketchData sketchData;
      if(b["master"] != null)
        masterData = UserShort(
            b["master"]["id"],
            b["master"]["name"],
            b["master"]["surname"],
            b["master"]["avatar"]
        );
      if(b["sketchData"] != null)
        sketchData = SketchData.fromJson(b["sketchData"]);
      OrderFull order = OrderFull(
        b["id"],
        b["status"],
        b["price"],
        b["name"],
        b["description"],
        b["isPrivate"],
        clientData,
        masterData,
        sketchData,
        DateTime.parse(b["created"])
      );
      if(b["services"] != null)
        for(var s in b["services"])
          order.services.add(s);
      if(b["sentences"] != null) {
        for(var s in b["sentences"]) {
          var sentence = Sentence(
            s["id"],
            s["masterId"],
            s["orderId"],
            s["price"],
            s["commentsCount"],
            s["message"],
            s["masterName"],
            s["masterSurname"],
            s["masterAvatar"],
            DateTime.parse(s["createdAt"]),
            []
          );
          order.sentences.add(sentence);
        }
      }
      print(order.toString());
      return order;
    }
    return null;
  }

  Future<bool> setMasterToOrder(ProfileProvider provider, int orderId, int masterId) async {
    var body = jsonEncode({
      "orderId": orderId,
      "masterId": masterId
    });
    var r = await http.post("http://10.0.2.2:8089/orders/set",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }

  Future<bool> updateOrderStatus(ProfileProvider provider, int orderId, int clientId, int masterId, int newStatus) async {
    var body = jsonEncode({
      "orderId": orderId,
      "clientId": clientId,
      "masterId": masterId,
      "status": newStatus
    });
    print("$body");
    var r = await http.post("http://10.0.2.2:8089/orders/status/update",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }
}