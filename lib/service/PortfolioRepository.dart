import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:style_app/model/PortfolioItem.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class PortfolioRepository {
  static PortfolioRepository _instance;

  static PortfolioRepository get() {
    if(_instance == null)
      _instance = PortfolioRepository();
    return _instance;
  }

  Future<PortfolioItem> createMasterPortfolioItem(ProfileProvider provider, PickedFile image) async {
    var request = http.MultipartRequest("POST", Uri.parse("$url/masters/portfolio/create"));
    request.files.add(await http.MultipartFile.fromPath('upload', image.path));
    request.headers.addAll(HeadersUtil.getAuthorizedHeaders(provider.token));

    var r = await request.send();
    String body;
    r.stream.transform(utf8.decoder).listen((value) {
      body = value;
      print("body => $body");
    });
    print("[${r.statusCode}] [$body]");

    return null;
  }

  Future<List<PortfolioItem>> getMasterPortfolio(ProfileProvider provider) async {
    var items = <PortfolioItem> [];
    var r = await http.get("$url/masters/portfolio/${provider.id}",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var i in b) {
        var portfolioItem = PortfolioItem.fromJson(i);
        items.add(portfolioItem);
      }
    }
    return items;
  }

  Future<bool> deletePortfolioItem(ProfileProvider provider, PortfolioItem portfolio) async {
    var body = jsonEncode({
      "portfolioId": portfolio.id
    });
    var r = await http.post("$url/masters/portfolio/delete",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }
}