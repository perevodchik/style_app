import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class UserService {

  static UserService _instance;

  static UserService get() {
    print("url = [$url]");
    if(_instance == null)
      _instance = UserService();
    return _instance;
  }

  Future<bool> isExist(String phone, int type) async {
    var r = await http.post(
      "$url/users/exist",
      headers: HeadersUtil.getHeaders(),
      body: jsonEncode({
        "phone": phone,
        "role": type
      })
    );
    print("[code ${r.statusCode}] [body ${r.body}]");
    return r.statusCode == 200;
  }

  Future<UserData> auth(String phone, String password, int type) async {
    var body = jsonEncode({
      "username": phone,
      "password": password,
      "role": type
    });
    print(body);
    var r = await http.post(
        "$url/login",
        body: body,
        headers: HeadersUtil.getHeaders());
    print("[code ${r.statusCode}] [body ${r.body}] [${r.headers}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      print(b);
      return await getCurrentUserByTokenAndRole(b["access_token"], type);
    }
    return null;
  }

  Future<UserData> getCurrentUserByTokenAndRole(String token, int type) async {
    var r = await http.get(
        "$url/users/current",
        headers: HeadersUtil.getAuthorizedHeaders(token));
    print("[${r.statusCode}]\n[${r.body}]\n[${r.headers}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      var user = UserData(
        b["id"],
        type,
        b["cityId"],
        b["commentsCount"] ?? 0,
        b["rate"] ?? 0.0,
        b["phone"],
        b["avatar"] ?? "",
        b["name"],
        b["surname"],
        b["address"] ?? "",
        b["about"] ?? "",
        b["email"] ?? "",
        b["isShowAddress"] ?? true,
        b["isShowPhone"] ?? true,
        b["isShowEmail"] ?? true,
        b["isRecorded"] ?? false,
        [],
        [],
        []
      );
      user.token = token;
      return user;
    }
    return null;
  }

  Future<UserData> register(UserData user, int role) async {
    var body = jsonEncode({
      "cityId": user.city,
      "phone": user.phone,
      "name": user.name,
      "surname": user.surname,
      "email": user.email,
      "role": role,
      "address": "",
      "avatar": ""
    });
    var r = await http.post("$url/users/create",
    headers: HeadersUtil.getHeaders(), body: body);
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      user.id = b["id"];
    }
    return user;
  }

  Future<bool> update(ProfileProvider profile, String name, String surname, String email, String address, String about, int cityId) async {
    var body = jsonEncode({
      "cityId": cityId,
      "name": name,
      "surname": surname,
      "email": email,
      "address": address,
      "avatar": "",
      "about": about,
      "phone": profile.phone,
      "isShowAddress": profile.isShowAddress,
      "isShowPhone": profile.isShowPhone,
      "isShowEmail": profile.isShowEmail,
    });

    var r = await http.post("$url/users/update",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token),
        body: body);
    print("[${r.statusCode}][${r.body}]");
    return r.statusCode == 200;
  }

  Future<bool> updatePrivacy(ProfileProvider provider, int setting, bool newValue) async {
    var body = jsonEncode({
      "setting": setting,
      "value": newValue
    });
    var r = await http.post("$url/users/privacy/update",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode.toString().startsWith("2")) {
      switch (setting) {
        case 0:
          provider.isShowAddress = newValue;
          break;
        case 1:
          provider.isShowPhone = newValue;
          break;
        case 2:
          provider.isShowEmail = newValue;
          break;
      }
      return true;
    }
    return false;
  }

  Future<UserData> getFullDataById(ProfileProvider provider, int masterId) async {
    var r = await http.get("$url/users/full/$masterId",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);

      var services = <Category> [];
      var comments = <CommentFull> [];
      if(b["services"] != null) {
        for(var c in b["services"]) {
          var cat = Category.fromJson(c);
          services.add(cat);
        }
      }

      if(b["comments"] != null) {
        for(var c in b["comments"]) {
          var comment = CommentFull(
            c["id"],
            c["commentatorId"],
            c["targetId"],
            c["commentatorName"],
            c["commentatorSurname"],
            c["commentatorAvatar"] ?? "",
            c["message"],
            c["rate"],
            DateTime.parse(c["createdAt"]),
          );
          comments.add(comment);
        }
      }

      var user = UserData(
        b["id"],
        b["role"],
        b["cityId"],
        b["commentsCount"] ?? 0,
        b["rate"] ?? 0.0,
        b["phone"],
        b["avatar"] ?? "",
        b["name"],
        b["surname"],
        b["address"] ?? "",
        b["about"] ?? "",
        b["email"] ?? "",
        b["isShowAddress"] ?? true,
        b["isShowPhone"] ?? true,
        b["isShowEmail"] ?? true,
        b["isRecorded"] ?? false,
        [],
        comments,
        services
      );

      var photos = ((b["photos"] ?? "") as String).split(",").map((i) => Photo(i, PhotoSource.NETWORK)).toList();
      print("photos is $photos");
      print("photos is ${photos.isEmpty}");
      print("photos length ${photos.length}");
      var photosForRemove = <Photo> [];
      for(var p in photos) {
        if(p.path.isEmpty || p.path.length < 2)
          photosForRemove.add(p);
      }
      for(var p in photosForRemove)
        photos.remove(p);
      print("photos is $photos");
      print("photos is ${photos.isEmpty}");
      print("photos length ${photos.length}");
      user.portfolioImages = photos;

      print("return ${user.toString()}");
      return user;
    }
    print("return null");
    return null;
  }

  Future<void> uploadAvatar(ProfileProvider profile, File file) async {
    var r = new http.MultipartRequest("POST", Uri.parse("$url/users/avatar"));
    r.files.add(await http.MultipartFile.fromPath(
      'upload',
      file.path
    ));
    r.headers.addAll(HeadersUtil.getAuthorizedHeaders(profile.token));
    r.send().then((response) async {
      var s = response.stream;
      var r = await s.bytesToString();
      profile.avatar = r;
    });
  }
}