class City {
  int id;
  String name;

  City(this.id, this.name);

  @override
  String toString() {
    return 'City{id: $id, name: $name}';
  }
}