import 'dart:convert';

import 'package:style_app/model/SentenceComment.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class SentencesRepository {
  static SentencesRepository _instance;

  static SentencesRepository get() {
    if(_instance == null)
      _instance = SentencesRepository();
    return _instance;
  }

  Future<List<SentenceComment>> sentenceCommentsBySentenceId(ProfileProvider profile, int sentenceId) async {
    var comments = <SentenceComment> [];
    var r = await http.get("$url/sentences/comments/$sentenceId",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var c in b) {
        var comment = SentenceComment.fromJson(c);
        comments.add(comment);
      }
    }
    return comments;
  }

  Future<SentenceComment> sendSentenceComment(ProfileProvider profile, int sentenceId, String message) async {
    var body = jsonEncode({
      "sentenceId": sentenceId,
      "message": message
    });
    print(body);
    var r = await http.post("$url/sentences/comments",
        headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      return SentenceComment.fromJson(b);
    }
    return null;
  }

}