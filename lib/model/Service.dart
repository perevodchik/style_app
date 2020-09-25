import 'package:style_app/model/ServiceWrapper.dart';

class Service {
  int id;
  int categoryId;
  String name;
  bool isTatoo;
  ServiceWrapper wrapper;

  Service(
      this.id, this.categoryId, this.name, {this.isTatoo, this.wrapper});

  factory Service.fromJson(Map<String, dynamic> json) => Service(
      json["id"],
      json["categoryId"],
      json["name"],
      isTatoo: json["isTatoo"] == null ? false : json["isTatoo"],
      wrapper: json["masterService"] != null ? ServiceWrapper.fromJson(json["masterService"]) : null
      );

  @override
  String toString() {
    return 'Service{id: $id, categoryId: $categoryId, name: $name, isTatoo: $isTatoo, wrapper: $wrapper}';
  }
}