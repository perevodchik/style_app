import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:style_app/model/City.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';

import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Sentence.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class OrdersService {
  static OrdersService _instance;

  static OrdersService get() {
    if(_instance == null)
      _instance = OrdersService();
    return _instance;
  }

  Future<Order> createOrder(ProfileProvider profile, Order order) async {
    var body = jsonEncode({
      "masterId": order.masterId,
      "price": order.price == null ? 0 : order.price,
      "name": order.name,
      "cityId": order.city,
      "description": order.description,
      "services": order.services.map((s) => s.id).toList(),
      "sketchData": order.sketch != null ? order.sketch.toJson() : null,
      "isPrivate": order.masterId != null,
      "status": order.masterId != null ? 3 : 0
    });
    print("body in [\n$body\n]");
    var r = await http.post(
      "$url/orders/create",
      body: body,
      headers: HeadersUtil.getAuthorizedHeaders(profile.token)
    );
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      order.id = b["id"];
    }
    print("[code ${r.statusCode}]\n[body ${r.body}]\n[${r.headers}]");
    return order;
  }

  Future<List<OrderAvailablePreview>> loadAvailableOrders(ProfileProvider provider, int page, int limit, {String filter = ""}) async {
    var orders = <OrderAvailablePreview> [];
    var r = await http.get("$url/orders/all?page=$page&limit=$limit${filter.isNotEmpty ? "&$filter" : ""}",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var a in b)
        orders.add(OrderAvailablePreview.fromJson(a));
    }
    return orders;
  }

  Future<List<OrderPreview>> loadUserOrders(ProfileProvider profile) async {
    var orders = <OrderPreview> [];
    var r = await http.get(
        "$url/orders/user",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token)
    );
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
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
    var r = await http.get("$url/orders/$orderId",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      UserShort masterData;
      SketchData sketchData;
      CommentFull clientComment;
      CommentFull masterComment;
      City city;
      var clientData = UserShort(
        b["client"]["id"],
        b["client"]["name"],
        b["client"]["surname"],
        Photo(b["client"]["avatar"], PhotoSource.NETWORK)
      );
      if(b["master"] != null)
        masterData = UserShort(
            b["master"]["id"],
            b["master"]["name"],
            b["master"]["surname"],
            Photo(b["master"]["avatar"], PhotoSource.NETWORK)
        );
      if(b["sketchData"] != null)
        sketchData = SketchData.fromJson(b["sketchData"]);
      if(b["clientComment"] != null)
        clientComment = CommentFull.fromJson(b["clientComment"]);
      if(b["masterComment"] != null)
        masterComment = CommentFull.fromJson(b["masterComment"]);
      if(b["city"] != null)
        city = City.fromJson(b["city"]);
      OrderFull order = OrderFull(
        b["id"],
        b["status"],
        b["price"],
        b["name"],
        b["description"] ?? "",
        // r.body,
        b["isPrivate"],
        clientData,
        masterData,
        sketchData,
        city,
        DateTime.parse(b["created"]),
        clientComment,
        masterComment
      );

      var photos = b["photos"] ?? "";
      if(photos.isEmpty || photos.length == 0)
        order.photos = [];
      else {
        order.photos = photos.split(",").map<Photo>((p) => Photo(p, PhotoSource.NETWORK)).toList();
      }

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
    var r = await http.post("$url/orders/set",
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
    var r = await http.post("$url/orders/status/update",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }

  Future<String> uploadOrderImage(ProfileProvider profile, int id, File file) async {
    var r = new http.MultipartRequest("POST", Uri.parse("$url/orders/upload"));
    r.files.add(await http.MultipartFile.fromPath(
        'upload',
        file.path
    ));
    r.fields["orderId"] = "$id";
    r.headers.addAll(HeadersUtil.getAuthorizedHeaders(profile.token));
    r.send().then((response) async {
      var s = response.stream;
      var r = await s.bytesToString();
      print("[${response.statusCode}] [$r]");
      return r;
    });
    return "";
  }

  Future<String> addExistingImage(ProfileProvider profile, int id, String path) async {
    var body = jsonEncode({
      "orderId": id,
      "image": path
    });
    var r = await http.post("$url/orders/uploadExist",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200)
      return r.body;
    return "";
  }
}