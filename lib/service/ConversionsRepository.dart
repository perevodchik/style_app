import 'dart:convert';
import 'dart:io';

import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Message.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class ConversionsRepository {
  static ConversionsRepository _instance;
  static ConversionsRepository get() {
    if(_instance == null)
      _instance = ConversionsRepository();
    return _instance;
  }

  Future<List<Conversion>> getConversions(ProfileProvider profile) async {
    var conversions = <Conversion> [];
    var r = await http.get("http://10.0.2.2:8089/conversions/get",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token)
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var c in b) {
        var conversion = Conversion(
          c["id"],
          c["lastReadMessageId"],
          c["message"] != null ?
          Message.fromJson(c["message"]) : Message(-1, c["id"], -1, "", DateTime.now()),
          UserShort.fromJson(c["user"]),
          true,
          c["canSendMessage"],
          []
        );
        conversion.isRead = conversion.lastReadMessageId >= conversion.lastMessage.id;
        print(conversion.toString());
        conversions.add(conversion);
      }
      conversions.sort((a, b) {
        return a.isRead ? 1 : 0;
      });
    }
    return conversions;
  }

  Future<Map<String, dynamic>> getMessagesByConversion(ProfileProvider profile, int conversionId, int page, int limit) async {
    var messages = <Message> [];
    var data = <String, dynamic> {};
    var r = await http.get("http://10.0.2.2:8089/conversions/$conversionId?page=$page&limit=$limit", headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData)["map"];
      data["canSendMessage"] = b["canSendMessages"];
      print(b["canSendMessages"]);
      print(b["messages"]["list"].length);
      for(var m in b["messages"]["list"]) {
        var message = Message.fromJson(m);
        messages.add(message);
      }
      data["messages"] = messages;
    }
    return data;
  }

  Future<Message> sendMessage(ProfileProvider profile, Message message, bool hasMedia) async {
    var body = jsonEncode({
      "id": -1,
      "conversionId": message.conversionId,
      "senderId": message.senderId,
      "message": message.text,
      "hasMedia": hasMedia,
      "createdAt": message.createdAt.toString()
    });
    print(body);
    var r = await http.post(
        "$url/conversions/send",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token),
        body: body
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      message.id = b["id"];
      message.createdAt = message.createdAt.toLocal();
    }
    return message;
  }

  Future<Message> sendMessageWithMedia(ProfileProvider profile, Message message, File file) async {
    var r = await http.post("$url/conversions/send", headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    return message;
  }
  
  Future<int> read(ProfileProvider profile , int conversionId, int messageId) async {
    var body = jsonEncode({
      "conversionId": conversionId,
      "messageId": messageId
    });
    var r = await http.post("$url/conversions/read",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode;
  }

  Future<String> uploadMedia(ProfileProvider profile, File file) async {
    var r = new http.MultipartRequest("POST", Uri.parse("$url/conversions/media"));
    r.files.add(await http.MultipartFile.fromPath(
        'upload',
        file.path
    ));
    r.headers.addAll(HeadersUtil.getAuthorizedHeaders(profile.token));
    var r0 = await r.send();
    var s = r0.stream;
    var r1 = await s.bytesToString();
    print("[${r0.statusCode}] [$r1]");
    return r1;
  }
}