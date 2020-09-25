class ServiceWrapper {
  int id;
  int serviceId;
  String description;
  int price;
  int time;

  ServiceWrapper(this.id, this.serviceId, this.price, this.time, this.description);

  factory ServiceWrapper.fromJson(Map<String, dynamic> json) => ServiceWrapper(
      json["id"],
      json["serviceId"],
      json["price"],
      json["time"],
      json["description"],
  );

  @override
  String toString() {
    return 'ServiceWrapper{id: $id, serviceId: $serviceId, description: $description, price: $price, time: $time}';
  }
}