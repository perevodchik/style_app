import 'dart:io';

class Message {
  int id;
  int conversionId;
  int senderId;
  String text;
  bool hasMedia;
  File media;

  Message(this.id, this.conversionId, this.senderId, this.text, {this.hasMedia = false});

  @override
  String toString() {
    return 'Message{id: $id, conversionId: $conversionId, senderId: $senderId, text: $text, hasMedia: $hasMedia}';
  }
}