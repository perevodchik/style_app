import 'package:style_app/model/MasterShortData.dart';
import 'package:style_app/model/Photo.dart';
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
  double rate;
  String avatar;
  String phone;
  String name;
  String surname;
  String address;
  String about;
  String email;
  String token;
  bool isShowAddress;
  bool isShowPhone;
  bool isShowEmail;
  bool isRecorded;
  List<Photo> portfolioImages;
  List<Sketch> sketches;
  List<CommentFull> comments;
  List<Category> services;

  UserData(this.id, this.profileType, this.city, this.commentsCount, this.rate, this.phone, this.avatar, this.name, this.surname, this.address, this.about, this.email,
      this.isShowAddress, this.isShowPhone, this.isShowEmail, this.isRecorded, this.portfolioImages, this.comments, this.services);

  bool checkCity(List<int> cities) {
    if(city == null)
      return false;
    for(var cityId in cities)
      if(cityId == city)
        return true;
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

  String getNames() {
    return "$name $surname";
  }

  List<ServiceWrapper> getServices() {
    return [];
  }

  @override
  String toString() {
    return 'UserData{id: $id, profileType: $profileType, city: $city, commentsCount: $commentsCount, rate: $rate, avatar: $avatar, phone: $phone, name: $name, surname: $surname, address: $address, about: $about, email: $email, token: $token, isShowAddress: $isShowAddress, isShowPhone: $isShowPhone, isShowEmail: $isShowEmail, isRecorded: $isRecorded, portfolioImages: $portfolioImages, sketches: $sketches, comments: $comments, services: $services}';
  }
}

class UserShortData {
  int id;
  int cityId;
  double rate;
  String name;
  String surname;
  Photo avatar;
  String portfolio;

  UserShortData(this.id, this.cityId, this.rate, this.name, this.surname,
      this.avatar, this.portfolio);

  factory UserShortData.fromJson(Map<String, dynamic> json) => UserShortData(
    json["id"],
    json["cityId"],
    json["rate"],
    json["name"],
    json["surname"],
    json["avatar"] != null ? Photo(json["avatar"], PhotoSource.NETWORK) : null,
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
  Photo avatar;

  UserShort(this.id, this.name, this.surname, this.avatar);

  factory UserShort.fromJson(Map<String, dynamic> json) => UserShort(
    json["id"],
    json["name"],
    json["surname"],
    json["avatar"] == null ? null : Photo(json["avatar"], PhotoSource.NETWORK)
  );

  @override
  String toString() {
    return 'UserShort{id: $id, name: $name, surname: $surname, avatar: $avatar}';
  }
}