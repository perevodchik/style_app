import 'package:style_app/model/Position.dart';
import 'package:style_app/model/Style.dart';

class Sketch {
  int id;
  int masterId;
  String masterFullName;
  SketchData data;
  bool isFavorite;
  bool isHide;
  List<String> photos = [];

  Sketch(this.id, this.masterId, this.masterFullName, this.data, this.isFavorite, this.isHide,
      this.photos);

  factory Sketch.fromJson(Map<String, dynamic> json) {
    print("Sketch json [ $json ]");
    return Sketch(
        json["id"],
        json["ownerId"],
        json["masterFullName"],
        SketchData.fromJson(json),
        json["isFavorite"] ?? false,
        json["isHide"] ?? false,
        json["photos"] != null ? (json["photos"] as String).split(",") : []
    );
  }

  Sketch clone() {
    var photos1 = <String>[];
    photos1.addAll(photos);
    var clonedSketch = Sketch(
        null,
        masterId,
        masterFullName,
        data.clone(),
        isFavorite,
        isHide,
        photos
    );
    return clonedSketch;
  }
}

class SketchPreview {
  int id;
  int masterId;
  int price;
  String photos;

  SketchPreview(this.id, this.masterId, this.price, this.photos);

  factory SketchPreview.fromJson(Map<String, dynamic> json) {
    print("SketchPreview json [ $json ]");
    return SketchPreview(
        json["id"],
        json["masterId"],
        json["price"],
        json["photos"] ?? ""
    );
  }

  @override
  String toString() {
    return 'SketchPReview{id: $id, masterId: $masterId, price: $price, photos: $photos}';
  }
}

class SketchData {
  int id;
  int width = 1;
  int height = 1;
  int price;
  String description;
  String tags = "tag1, tag2";
  bool isColored = true;
  Position position;
  Style style;

  SketchData({this.id, this.width, this.height, this.price, this.description,
    this.tags, this.isColored, this.position, this.style});

  Map<String, dynamic> toJson() {
    return {
    "positionId": position.id,
    "styleId": style.id,
    "width": width,
    "height": height,
    "isColored": isColored
    };
  }

  factory SketchData.fromJson(Map<String, dynamic> json) {
    print("sketchData json [ $json ]");
    return SketchData(
        id: json["id"] ?? 0,
        width: json["width"],
        height: json["height"],
        price: json["price"],
        description: json["description"] ?? "",
        tags: json["tags"] ?? "",
        isColored: json["isColored"] ?? false,
        position: Position(
            json["position"]["id"],
            json["position"]["name"]
          ),
        style: Style(
            json["style"]["id"],
            json["style"]["name"]
        )
    );
  }

  @override
  String toString() {
    return 'SketchData{id: $id, width: $width, height: $height, price: $price, description: $description, tags: $tags, isColored: $isColored, position: $position, style: $style}';
  }

  SketchData clone() {
    var clonedData = SketchData();
    clonedData.id = id;
    clonedData.width = width;
    clonedData.height = height;
    clonedData.price = price;
    clonedData.tags = tags;
    clonedData.description = description;
    clonedData.isColored = isColored;
    clonedData.style = style;
    clonedData.position = position;
    return clonedData;
  }
}