class City {
  int id;
  String name;

  City(this.id, this.name);

  factory City.fromJson(Map<String, dynamic> json) => City(
    json["id"],
    json["name"]
  );

  @override
  String toString() {
    return 'City{id: $id, name: $name}';
  }
}