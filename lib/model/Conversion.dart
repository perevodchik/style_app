import 'package:style_app/model/Message.dart';

class Conversion {
  int id;
  int masterId;
  int clientId;
  List<Message> messages;

  Conversion(this.id, this.masterId, this.clientId, this.messages);

  @override
  String toString() {
    return 'Conversion{id: $id, masterId: $masterId, clientId: $clientId, messages: ${messages.toString()}';
  }
}