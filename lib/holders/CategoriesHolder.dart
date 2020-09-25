import 'package:style_app/model/Category.dart';
import 'package:style_app/model/Service.dart';

class CategoriesHolder {
  static List<Category> categories = [];

  static Service getServiceById(int id) {
    for(var c in categories)
      for(var s in c?.services)
        if(s.id == id)
          return s;
    return null;
  }

  static Service getTatooService() {
    for(var c in categories) {
      for(var s in c.services)
        if(s.isTatoo)
          return s;
    }
    return null;
  }
}