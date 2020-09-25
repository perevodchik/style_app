import 'package:flutter/widgets.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/holders/UserHolder.dart';

class ProfileProvider extends ChangeNotifier {
  int get profileType => UserHolder.profileType;
  int get city => UserHolder.city;
  int get id => UserHolder.id;
  String get token => UserHolder.token;
  String get name => UserHolder.name;
  String get surname => UserHolder.surname;
  String get phone => UserHolder.phone;
  String get email => UserHolder.email;
  String get address => UserHolder.address;
  bool get isShowAddress => UserHolder.isShowAddress;
  bool get isShowPhone => UserHolder.isShowPhone;
  bool get isShowEmail => UserHolder.isShowEmail;
  List<ServiceWrapper> get services => UserHolder.services;
  List<Sketch> get sketches => UserHolder.sketches;
  List<String> get portfolioImages => UserHolder.portfolioImages;

  set profileType(int val) {
    UserHolder.profileType = val;
    notifyListeners();
  }

  set city(int val) {
    UserHolder.city = val;
    notifyListeners();
  }

  set id(int val) {
    UserHolder.id = val;
    notifyListeners();
  }

  set token(String val) {
    UserHolder.token = val;
    notifyListeners();
  }

  set name(String val) {
    UserHolder.name = val;
    notifyListeners();
  }

  set surname(String val) {
    UserHolder.surname = val;
    notifyListeners();
  }

  set phone(String val) {
    UserHolder.phone = val;
    notifyListeners();
  }

  set email(String val) {
    UserHolder.email = val;
    notifyListeners();
  }

  set address(String val) {
    UserHolder.address = val;
    notifyListeners();
  }

  set isShowAddress(bool val) {
    UserHolder.isShowAddress = val;
    notifyListeners();
  }

  set isShowPhone(bool val) {
    UserHolder.isShowPhone = val;
    notifyListeners();
  }

  set isShowEmail(bool val) {
    UserHolder.isShowEmail = val;
    notifyListeners();
  }

  bool containsService(ServiceWrapper serviceWrapper) {
    for(var wrapper in services) {
      if(wrapper.serviceId == serviceWrapper.serviceId)
        return true;
    }
    return false;
  }

  void toggleService(ServiceWrapper val) {
    for(var wrapper in services) {
      if(wrapper.serviceId == val.serviceId) {
        services.remove(wrapper);
        notifyListeners();
        return;
      }
    }
    UserHolder.services.add(val);
    notifyListeners();
  }

  ServiceWrapper wrapperByService(Service service) {
    for(var wrapper in services)
      if(wrapper.serviceId == service.id)
        return wrapper;
    return null;
  }

  void updateWrapper(ServiceWrapper anotherWrapper) {
    for(var wrapper in services)
      if(wrapper.serviceId == anotherWrapper.serviceId) {
        wrapper.description = anotherWrapper.description;
        wrapper.price = anotherWrapper.price;
        wrapper.time = anotherWrapper.time;
        return;
      }
  }

  void update() => notifyListeners();

  void set(UserData userData, List<Sketch> sketchesList) {
    UserHolder.token = userData.token;
    UserHolder.profileType = userData.profileType;
    UserHolder.id = userData.id;
    UserHolder.city = userData.city;
    UserHolder.name = userData.name;
    UserHolder.surname = userData.surname;
    UserHolder.phone = userData.phone;
    UserHolder.email = userData.email;
    UserHolder.address = userData.address;
    UserHolder.isShowAddress = userData.isShowAddress;
    UserHolder.isShowPhone = userData.isShowPhone;
    UserHolder.isShowEmail = userData.isShowEmail;
    UserHolder.services.clear();
    UserHolder.services.addAll(userData.getServices());
    UserHolder.sketches.clear();
    UserHolder.sketches.addAll(sketchesList);
    notifyListeners();
  }

  void addPortfolioImages(String image) {
    UserHolder.portfolioImages.insert(0, image);
    notifyListeners();
  }

  removePortfolioImage(String image) {
    UserHolder.portfolioImages.remove(image);
    notifyListeners();
  }

  void tick() {
    notifyListeners();
  }
}