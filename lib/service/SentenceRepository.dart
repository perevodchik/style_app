import 'dart:convert';

import 'package:style_app/model/Sentence.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class SentenceRepository {

  static SentenceRepository _instance;

  static SentenceRepository get() {
    if(_instance == null)
      _instance = SentenceRepository();
    return _instance;
  }

  Future<Sentence> createSentence(ProfileProvider profile, int orderId, int price, String message) async {
    var body = jsonEncode({
      "orderId": orderId,
      "masterId": profile.id,
      "price": price,
      "message": message
    });
    var r = await http.post("$url/sentences/create",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      var sentence = Sentence(
        b["id"],
        b["masterId"],
        b["orderId"],
        b["price"],
        b["commentsCount"],
        b["message"],
        profile.name,
        profile.surname,
        "",
        DateTime.parse(b["createdAt"]),
        []
      );
      return sentence;
    }
    return null;
  }

}