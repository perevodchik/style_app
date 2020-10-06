import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Record.dart';

class Notification {
  int id;
  int notificationType;
  UserShort user;
  UserShort secondUser;
  OrderName order;
  bool isDirty;
  DateTime createdAt;

  Notification(this.id, this.notificationType, this.user, this.secondUser, this.order, this.isDirty, this.createdAt);

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    json["id"],
    json["notificationType"],
    json["user"] != null ? UserShort.fromJson(json["user"]) : null,
    json["secondUser"] != null ? UserShort.fromJson(json["secondUser"]) : null,
    json["order"] != null ? OrderName.fromJson(json["order"]) : null,
    json["isDirty"],
    DateTime.parse(json["createdAt"])
  );

  @override
  String toString() {
    return 'Notification{id: $id, notificationType: $notificationType, user: $user, secondUser: $secondUser, order: $order, isDirty: $isDirty, createdAt: $createdAt}';
  }
}