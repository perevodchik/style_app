import 'dart:convert';

import 'package:style_app/model/Comment.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class CommentsRepository {
  static CommentsRepository _instance;

  static CommentsRepository get() {
    if(_instance == null)
      _instance = CommentsRepository();
    return _instance;
  }

  Future<Comment> createComment(ProfileProvider profile, int targetId, int orderId, double rate, String message) async {
    var body = jsonEncode({
      "commentatorId": profile.id,
      "targetId": targetId,
      "orderId": orderId,
      "rate": rate,
      "message": "$message"
    });
    print(body);
    var r = await http.post("$url/comments/create",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      return Comment.fromJson(b);
    }
    return null;
  }

  Future<List<CommentFull>> commentsByUserId(ProfileProvider profile, int id) async {
    var comments = <CommentFull> [];

    var r = await http.get("$url/comments/list/$id",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var c in b) {
        var comment = CommentFull.fromJson(c);
        comments.add(comment);
      }
    }

    return comments;
  }
}