import 'package:style_app/model/Category.dart';
import 'package:style_app/model/Service.dart';

class CategoryService {
  // static Map<Category, List<Service>> services = {
    // Category(0, "name 0"): [
    //   Service(1, "service 1"),
    //   Service(2, "service 2")
    // ],
    // Category(1, "name 1"): [
    //   Service(4, "service 4"),
    //   Service(5, "service 5"),
    //   Service(6, "service 6"),
    //   Service(7, "service 7")
    // ],
    // Category(2, "name 2"): [
    //   Service(8, "Татуировка")],
    // Category(3, "name 3"): [],
  // };

  Service getServiceById(int id) {
    // for(var list in services.values) {
    //   for(var service in list)
    //     if(service.id == id)
    //       return service;
    // }
    return null;
  }

  List<Service> getServicesFromOrder(List<dynamic> servicesIds) {
    // var s = <Service> [];
    // for(var list in services.values) {
    //   for(var service in list)
    //     if(servicesIds.contains(service.id))
    //       s.add(service);
    // }
    // return s;
    return null;
  }
}