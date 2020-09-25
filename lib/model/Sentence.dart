import 'package:style_app/model/SentenceComment.dart';

class Sentence {
  int id;
  int masterId;
  int orderId;
  int price;
  int commentsCount;
  String text;
  String masterName;
  String masterSurname;
  String masterAvatar;
  DateTime createDate;
  List<SentenceComment> comments;

  Sentence(
      this.id,
      this.masterId,
      this.orderId,
      this.price,
      this.commentsCount,
      this.text,
      this.masterName,
      this.masterSurname,
      this.masterAvatar,
      this.createDate,
      this.comments
      );

  @override
  String toString() {
    return 'Sentence{id: $id, masterId: $masterId, orderId: $orderId, price: $price, commentsCount: $commentsCount, text: $text, masterName: $masterName, masterSurname: $masterSurname, masterAvatar: $masterAvatar, createDate: $createDate, comments: $comments}';
  }
}