import 'dart:convert';

import 'package:style_app/model/Comment.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/utils/HeadersUtil.dart';

class CommentsRepository {
  static CommentsRepository _instance;

  static CommentsRepository get() {
    if(_instance == null)
      _instance = CommentsRepository();
    return _instance;
  }

  Future<Comment> createComment(ProfileProvider profile, int targetId, double rate, String message) async {
    var body = jsonEncode({
      "commentatorId": profile.id,
      "targetId": targetId,
      "rate": rate,
      "message": "$message"
    });
    print(body);
    var r = await http.post("http://10.0.2.2:8089/comments/create",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      return Comment.fromJson(b);
    }
    return null;
  }
}