import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/model/Position.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class PositionsRepository {

  static PositionsRepository _instance;

  static PositionsRepository get() {
    if(_instance == null)
      _instance = PositionsRepository();
    return _instance;
  }

  Future<List<Position>> getAllPositions(ProfileProvider provider) async {
    var positions = <Position> [];
    var r = await http.get("http://10.0.2.2:8089/positions/all",
      headers: HeadersUtil.getAuthorizedHeaders(provider.token)
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var p in b) {
        var position = Position(
            p["id"],
            p["name"]
        );
        positions.add(position);
      }
    }

    return positions;
  }

}