class PortfolioItem {
  int id;
  int masterId;
  String image;

  PortfolioItem(this.id, this.masterId, this.image);

  factory PortfolioItem.fromJson(Map<String, Object> json) => PortfolioItem(
    json["id"],
    json["masterId"],
    json["image"]
  );

  @override
  String toString() {
    return 'PortfolioItem{id: $id, masterId: $masterId, image: $image}';
  }
}