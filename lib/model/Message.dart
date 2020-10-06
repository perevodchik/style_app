import 'dart:io';

class Message {
  int id;
  int conversionId;
  int senderId;
  String text;
  DateTime createdAt;
  bool hasMedia;
  File media;

  Message(this.id, this.conversionId, this.senderId, this.text, this.createdAt, {this.hasMedia = false});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      json["id"],
      json["conversionId"],
      json["senderId"],
      json["message"] ?? "",
      json["createdAt"] == null ? DateTime.now() : DateTime.parse(json["createdAt"]).toLocal(),
      hasMedia: json["hasMedia"] ?? false
  );

  @override
  String toString() {
    return 'Message{id: $id, conversionId: $conversionId, senderId: $senderId, text: $text, hasMedia: $hasMedia}';
  }
}