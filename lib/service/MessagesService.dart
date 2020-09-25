//import 'package:style_app/model/Conversion.dart';
//import 'package:style_app/model/Message.dart';
//import 'package:style_app/service/MastersRepository.dart';
//
//class MessagesService {
//  static List<Conversion> conversions = [
//    Conversion(0, 113, 2),
//    Conversion(1, 113, 1)
//  ];
//  static List<Message> messages = [
//    Message(0, 1, 1, "message 1"),
//    Message(1, 0, 0, "message 2"),
//    Message(2, 2, 113, "message 3"),
//    Message(3, 2, 0, "message 4"),
//    Message(4, 2, 113, "message 5"),
//    Message(5, 1, 0, "message 6"),
//    Message(6, 1, 1, "message 7"),
//    Message(7, 1, 1, "message a"),
//    Message(8, 1, 113, "message q"),
//    Message(9, 1, 0, "message w"),
//  ];
//
//  void sendMessage(Message message) {
//    messages.insertAll(0, <Message> [message]);
//  }
//
//  Conversion getConversion(int clientId, int masterId) {
//    for(var c in conversions)
//      if(c.clientId == clientId && c.masterId == masterId)
//        return c;
//
//    var newConversion = Conversion(3232, masterId, clientId);
//    conversions.add(newConversion);
//    return newConversion;
//  }
//
//  List<Message> getMessagesByConversion(int conversionId) {
//    List<Message> findMessages = [];
//    for(var m in messages) {
//      if(m.conversionId == conversionId)
//        findMessages.add(m);
//    }
//    return findMessages;
//  }
//
//  Message getLastMessageFromConversion(int conversionId) {
//    var message;
//    for(var m in getMessagesByConversion(conversionId)) {
//      if(message == null)
//        message = m;
//      else if(m.id > message.id)
//        message = m;
//    }
//    return message;
//  }
//}