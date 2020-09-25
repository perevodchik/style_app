import 'dart:convert';

import 'package:style_app/model/Sentence.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/providers/ProfileProvider.dart';
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
    var r = await http.post("http://10.0.2.2:8089/sentences/create",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
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