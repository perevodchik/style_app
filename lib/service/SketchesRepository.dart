import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:style_app/holders/PositionsHolder.dart';
import 'package:style_app/holders/StylesHolder.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class SketchesRepository {
  static SketchesRepository _instance;

  static SketchesRepository get() {
    if(_instance == null)
      _instance = SketchesRepository();
    return _instance;
  }

  Future<Sketch> getSketchById(ProfileProvider provider, int id) async {
    Sketch sketch;
    var r = await http.get("$url/sketches/$id",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token)
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      sketch = Sketch.fromJson(b);
    }
    return sketch;
  }

  Future<List<SketchPreview>> getMasterSketchesPreviews(ProfileProvider provider, int userId) async {
    var previews = <SketchPreview> [];
    var r = await http.get("$url/sketches/master/$userId",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var p in b) {
        var preview = SketchPreview.fromJson(p);
        previews.add(preview);
      }
    }
    return previews;
  }

  Future<Sketch> createSketch(ProfileProvider provider, Sketch sketch) async {
    var body = jsonEncode({
      "ownerId": provider.id,
      "price": sketch.data.price,
      "width": sketch.data.width,
      "height": sketch.data.height,
      "time": 0,
      "positionId": sketch.data.position.id,
      "styleId": sketch.data.style.id,
      "tags": sketch.data.tags,
      "description": sketch.data.description,
      "photos": "",
      "isColored": sketch.data.isColored
    });
    print(body);
    
    var r = await http.post("$url/sketches/create",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      sketch.id = b["id"];
    }

    print("[${r.statusCode}] [${r.body}]");
    return sketch;
  }

  Future<String> uploadSketchImage(ProfileProvider profile, int sketchId, File file) async {
    var r = new http.MultipartRequest("POST", Uri.parse("$url/sketches/upload"));
    r.files.add(await http.MultipartFile.fromPath(
        'upload',
        file.path
    ));
    r.fields["sketchId"] = "$sketchId";
    r.headers.addAll(HeadersUtil.getAuthorizedHeaders(profile.token));
    r.send().then((response) async {
      var s = response.stream;
      var r = await s.bytesToString();
      print("[${response.statusCode}] [$r]");
      return r;
    });
    return "";
  }

  Future<List<Sketch>> getSketchesByMasterId(ProfileProvider provider) async {
    var sketches = <Sketch> [];
    var r = await http.get("$url/sketches/master/${provider.id}",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var s in b) {
        var data = SketchData();
        data.price = s["proce"];
        data.width = s["width"];
        data.height = s["height"];
        data.tags = s["tags"];
        data.description = s["description"];
        data.position = PositionsHolder.positionById(s["positionId"]);
        data.style = StylesHolder.styleById(s["styleId"]);
        var sketch = Sketch(s["id"], s["ownerId"], s["masterFullName"], data, false, false, []);
        sketches.add(sketch);
      }
    }
    return sketches;
  }

  Future<List<SketchPreview>> loadSketches(ProfileProvider provider, int page, int perPage, {String filter = ""}) async {
    var sketches = <SketchPreview> [];
    var r = await http.get("$url/sketches/list?page=$page&limit=$perPage${filter.isNotEmpty ? "&$filter" : filter}",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var p in b) {
        var preview = SketchPreview.fromJson(p);
        sketches.add(preview);
      }
    }
    return sketches;
  }

  Future<bool> likeSketch(ProfileProvider provider, bool isFavorite, int sketchId) async {
    var body = jsonEncode({
      "sketchId": sketchId
    });
    var r = await http.post("$url/sketches/${isFavorite ? "unlike" : "like"}",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token),
        body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }

  Future<bool>deleteSketch(ProfileProvider provider, Sketch sketch) async {
    var body = jsonEncode({
      "sketchId": sketch.id
    });
    print(body);
    var r = await http.post("$url/sketches/delete",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);
    print("[${r.statusCode}] [${r.body}]");
    return r.statusCode == 200;
  }
}