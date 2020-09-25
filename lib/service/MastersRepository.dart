import 'dart:convert';

import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/utils/HeadersUtil.dart';

class MastersRepository {
  static MastersRepository _instance;
  static List<UserData> masterDataList = [ ];
  static int counter = 0;

  static List<UserData> clientDataList = [ ];

  static MastersRepository get() {
    if(_instance == null)
      _instance = MastersRepository();
    return _instance;
  }



  UserData findById(int id) {
    for (var masterData in masterDataList)
      if (masterData.id == id) return masterData;
    return null;
  }

  void addComment(int masterId, CommentFull comment) {
    findById(masterId)?.comments?.insert(0, comment);
  }

  UserData getClientById(int clientId) {
    return clientDataList.where((client) => client.id == clientId).first;
  }
  UserData getMasterById(int masterId) {
    return masterDataList.firstWhere((client) => client.id == masterId);
  }

  Future<List<UserShortData>> loadMastersList(ProfileProvider profile, int page, int perPage) async {
    var list = <UserShortData> [];
    var r = await http.get("http://10.0.2.2:8089/masters/list?page=$page&limit=$perPage",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var m in b) {
        list.add(UserShortData.fromJson(m));
      }
    }

    return list;
  }
}