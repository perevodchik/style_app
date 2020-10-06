import 'dart:convert';

import 'package:style_app/model/MasterData.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class MastersRepository {
  static MastersRepository _instance;

  static MastersRepository get() {
    if(_instance == null)
      _instance = MastersRepository();
    return _instance;
  }

  Future<List<UserShortData>> loadMastersList(ProfileProvider profile, int page, int perPage, {String filter = ""}) async {
    var list = <UserShortData> [];
    var r = await http.get("$url/masters/list?page=$page&limit=$perPage${filter.isNotEmpty ? "&$filter" : filter}",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var m in b) {
        list.add(UserShortData.fromJson(m));
      }
    }

    return list;
  }
}