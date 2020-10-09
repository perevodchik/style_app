import 'package:style_app/model/Photo.dart';

class PortfolioItem {
  int id;
  int masterId;
  Photo image;

  PortfolioItem(this.id, this.masterId, this.image);

  factory PortfolioItem.fromJson(Map<String, Object> json) => PortfolioItem(
    json["id"],
    json["masterId"],
    Photo(json["image"], PhotoSource.NETWORK)
  );

  @override
  String toString() {
    return 'PortfolioItem{id: $id, masterId: $masterId, image: $image}';
  }
}