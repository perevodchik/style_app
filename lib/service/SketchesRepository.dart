import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:style_app/holders/PositionsHolder.dart';
import 'package:style_app/holders/StylesHolder.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/ProfileProvider.dart';
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
    var r = await http.get("http://10.0.2.2:8089/sketches/$id",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token)
    );
    print("[${r.statusCode}] [${r.body}]");
    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      sketch = Sketch.fromJson(b);
    }
    return sketch;
  }

  Future<List<SketchPreview>> getMasterSketchesPreviews(ProfileProvider provider) async {
    var previews = <SketchPreview> [];
    var r = await http.get("http://10.0.2.2:8089/sketches/master/${provider.id}",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
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
    
    var r = await http.post("http://10.0.2.2:8089/sketches/create",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token),
    body: body);

    print("[${r.statusCode}] [${r.body}]");

    return sketch;
  }

  Future<List<Sketch>> getSketchesByMasterId(ProfileProvider provider) async {
    var sketches = <Sketch> [];
    var r = await http.get("http://10.0.2.2:8089/sketches/master/${provider.id}",
    headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
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

  Future<List<SketchPreview>> loadSketches(ProfileProvider provider, int page, int perPage) async {
    var sketches = <SketchPreview> [];

    var r = await http.get("http://10.0.2.2:8089/sketches/list?page=$page&limit=$perPage",
        headers: HeadersUtil.getAuthorizedHeaders(provider.token));
    print("[${r.statusCode}] [${r.body}]");

    if(r.statusCode == 200) {
      var b = jsonDecode(r.body);
      for(var p in b) {
        var preview = SketchPreview.fromJson(p);
        sketches.add(preview);
      }
    }

    return sketches;
  }
}