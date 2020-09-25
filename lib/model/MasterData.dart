import 'package:style_app/model/MasterShortData.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/model/Sketch.dart';

import 'Category.dart';
import 'Comment.dart';
import 'Service.dart';

class UserData {
  int id;
  int profileType;
  int city;
  int commentsCount;
  String avatar;
  String phone;
  String name;
  String surname;
  String address;
  String email;
  String token;
  bool isShowAddress;
  bool isShowPhone;
  bool isShowEmail;
  List<String> portfolioImages;
  List<Sketch> sketches;
  List<CommentFull> comments;
  List<Category> services;

  UserData(this.id, this.profileType, this.city, this.commentsCount, this.phone, this.avatar, this.name, this.surname, this.address, this.email,
      this.isShowAddress, this.isShowPhone, this.isShowEmail, this.portfolioImages, this.comments, this.services);

  bool checkCity(List<int> cities) {
    if(city == null)
      return false;
    for(var cityId in cities)
      if(cityId == city)
        return true;
    return false;
  }

  bool checkService(List<Service> filterServices) {
    // if(services.isEmpty)
    //   return false;
    //
    // for(var serviceList in services.values)
    //   for(var s in serviceList)
    //     for(var ss in filterServices)
    //       if(s.id == ss.id)
    //         return true;

    return false;
  }

  double getAverageRate() {
    if(comments.isEmpty)
      return 0;
    double rate = 0;
    for(var comment in comments) {
      rate += comment.rate;
    }
    return rate / comments.length;
  }

  ProfileShortData toShortData() {
    return ProfileShortData(id, avatar, name, surname, getAverageRate());
  }

  String getNames() {
    return "$name $surname";
  }

  List<ServiceWrapper> getServices() {
    // var returnedServices = <ServiceWrapper> [];
    // for(var e in services.values)
    //   returnedServices.addAll(e);
    // return returnedServices;
    // return services;
    return [];
  }

  @override
  String toString() {
    return 'UserData{id: $id, profileType: $profileType, city: $city, avatar: $avatar, phone: $phone, name: $name, surname: $surname, address: $address, email: $email, token: $token, isShowAddress: $isShowAddress, isShowPhone: $isShowPhone, isShowEmail: $isShowEmail, portfolioImages: $portfolioImages, sketches: $sketches, comments: $comments, services: $services}';
  }
}

class UserShortData {
  int id;
  int cityId;
  double rate;
  String name;
  String surname;
  String avatar;
  String portfolio;

  UserShortData(this.id, this.cityId, this.rate, this.name, this.surname,
      this.avatar, this.portfolio);

  factory UserShortData.fromJson(Map<String, dynamic> json) => UserShortData(
    json["id"],
    json["cityId"],
    json["rate"],
    json["name"],
    json["surname"],
    json["avatar"],
    json["portfolio"]
  );

  @override
  String toString() {
    return 'UserShortData{id: $id, cityId: $cityId, rate: $rate, name: $name, surname: $surname, avatar: $avatar, portfolio: $portfolio}';
  }
}

class UserShort {
  int id;
  String name;
  String surname;
  String avatar;

  UserShort(this.id, this.name, this.surname, this.avatar);

  @override
  String toString() {
    return 'UserShort{id: $id, name: $name, surname: $surname, avatar: $avatar}';
  }
}