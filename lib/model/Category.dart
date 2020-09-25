import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';

class Category {
  int id;
  String name;
  List<Service> services = <Service> [];
  String icon = "Icons.visibility";

  Category(this.id, this.name, {this.services, this.icon});

  bool isHaveServiceWrapper() {
    for(var s in services)
      if(s.wrapper != null)
        return true;
    return false;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    var category = Category(
        json["id"],
        json["name"],
        services: [],
        icon: "");

    if(json["services"] != null) {
      for(var s in json["services"]) {
        var service = Service(
            s["id"],
            s["categoryId"],
            s["name"],
            isTatoo: s["isTatoo"] ?? false
        );
        if(s["masterService"] != null) {
          var wrapper = ServiceWrapper.fromJson(s["masterService"]);
          service.wrapper = wrapper;
        }
        category.services.add(service);
      }
    }

    return category;
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, services: $services, icon: $icon}';
  }
}