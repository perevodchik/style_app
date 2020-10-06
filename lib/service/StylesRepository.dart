import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/model/Style.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class StylesRepository {

  static StylesRepository _instance;

  static StylesRepository get() {
    if(_instance == null)
      _instance = StylesRepository();
    return _instance;
  }

  Future<List<Style>> getAllStyles(ProfileProvider provider) async {
    var styles = <Style> [];

    var r = await http.get("$url/styles/all",
      headers: HeadersUtil.getAuthorizedHeaders(provider.token)
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var p in b) {
        var style = Style(
            p["id"],
            p["name"]
        );
        styles.add(style);
      }
    }

    return styles;
  }

}