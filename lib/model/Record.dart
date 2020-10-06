import 'package:style_app/model/City.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/model/Sentence.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/Sketch.dart';

class Order {
  int id;
  int clientId;
  int masterId;
  int price;
  int status;
  int city;
  int sentenceId;
  String name;
  String description;
  bool isPrivate;
  SketchData sketch;
  DateTime createDate;
  List<Service> services;
  List<Photo> media;
  List<Sentence> sentences;

  Order(
      this.id,
      this.clientId,
      this.masterId,
      this.price,
      this.status,
      this.city,
      this.name,
      this.description,
      this.services,
      this.media,
      this.isPrivate,
      this.createDate,
      this.sentences,
      {this.sketch});

  List<Sentence> sentencesFromMaster(int masterId) {
    return sentences.where((sentence) => sentence.masterId == masterId).toList();
  }

  addSentence(Sentence sentence) {
    print("add sentence $sentence");
    for(var s in sentences) {
      if(s.masterId == sentence.masterId) {
        if(sentence.price != null)
          if(sentence.price > 0)
            s.price = sentence.price;
        if(sentence.text != null)
          if(sentence.text.length > 0)
            s.text = sentence.text;
        s.createDate = s.createDate;
        return;
      }
    }
    sentences.add(sentence);
  }

  @override
  String toString() {
    return 'Record{id: $id, '
        'clientId: $clientId, '
        'masterId: $masterId, '
        'price: $price, '
        'status: $status, '
        'name: $name, '
        'description: $description, '
        'isPrivate: $isPrivate, '
        'services: $services, '
        'media: $media, '
        'isPrivate: $isPrivate, '
        'createDate: $createDate, '
        'sketch: $sketch, '
        'sentences: $sentences}';
  }

  String getStatus() {
    if(status == 0)
      return "В ожидании";
    else if(status == 1)
      return "Завершена";
    else if(status == 2)
      return "В процессе";
    else if(status == 3)
      return "Ожидает подтверждения";
    else if(status == 4)
      return "Отменена";
    return "---";
  }
}

class OrderPreview {
  int id;
  int price;
  int status;
  int sentencesCount;
  String name;

  OrderPreview(this.id, this.price, this.status, this.sentencesCount, this.name);

  @override
  String toString() {
    return 'OrderPreview{id: $id, price: $price, status: $status, name: $name}';
  }
}

class OrderFull {
  int id;
  int status;
  int price;
  String name;
  String description;
  bool isPrivate;
  UserShort client;
  UserShort master;
  SketchData sketchData;
  City city;
  DateTime created;
  List<Photo> photos = [];
  List<String> services = [];
  List<Sentence> sentences = [];
  CommentFull clientComment;
  CommentFull masterComment;

  OrderFull(this.id, this.status, this.price, this.name, this.description,
      this.isPrivate, this.client, this.master, this.sketchData, this.city, this.created, this.clientComment, this.masterComment);

  @override
  String toString() {
    return 'OrderFull{id: $id, status: $status, price: $price, name: $name, isPrivate: $isPrivate, client: $client, master: $master, sketchData: $sketchData, city: $city, created: $created, photos: $photos, services: $services, sentences: $sentences, clientComment: $clientComment, masterComment: $masterComment}';
  }
}

class OrderAvailablePreview {
  int id;
  int price;
  String name;
  String description;
  DateTime created;

  OrderAvailablePreview(
      this.id, this.price, this.name, this.description, this.created);

  factory OrderAvailablePreview.fromJson(Map<String, dynamic> json) => OrderAvailablePreview(
    json["id"],
    json["price"],
    json["name"],
    json["description"] ?? "",
    DateTime.parse(json["created"])
  );

  @override
  String toString() {
    return 'OrderAvailablePreview{id: $id, price: $price, name: $name, description: $description, created: $created}';
  }
}

class OrderName {
  int id;
  String name;

  OrderName(this.id, this.name);

  factory OrderName.fromJson(Map<String, dynamic> json) => OrderName(
      json["id"],
      json["name"]
  );
}