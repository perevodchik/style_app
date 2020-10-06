import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Message.dart';
import 'package:style_app/utils/Widget.dart';

class Conversion {
  int id;
  int lastReadMessageId;
  Message lastMessage;
  UserShort userShort;
  bool isRead = false;
  bool canSendMessage = false;
  List<Message> messages = [];

  Conversion(
      this.id, this.lastReadMessageId, this.lastMessage, this.userShort, this.isRead, this.canSendMessage, this.messages);

  @override
  String toString() {
    return 'Conversion{id: $id, lastReadMessageId: $lastReadMessageId, isRead: $isRead, canSendMessage: $canSendMessage, lastMessage: $lastMessage, userShort: $userShort, messages: $messages}';
  }

  String getLastMessageTime() {
    if(lastMessage == null)
      return "";
    var now = DateTime.now();
    if(now.isDateEquals(lastMessage.createdAt))
      return lastMessage.createdAt.getTime();
    else return lastMessage.createdAt.getDate();
  }
}