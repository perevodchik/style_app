import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Message.dart';

class ConversionProvider extends ChangeNotifier {
  List<Conversion> _conversions = [
    Conversion(0, 0, 113, [
      Message(0, 0, 113, "OLA"),
      Message(0, 0, 0, "HELO"),
    ]),
    Conversion(1, 2, 113, [])
  ];
  List<Message> _messages = [];

  List<Conversion> get conversions => _conversions;
//  List<Message> get messages => _messages;

  set conversions(List<Conversion> newConversions) {
    _conversions = newConversions;
    notifyListeners();
  }

  set messages(List<Message> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }

  void sendMessage(Conversion conversion, Message message) {
    conversion.messages.insert(0, message);
    print("${conversion.toString()}");
    notifyListeners();
  }

  List<Conversion> getConversionsByMaster(int id) {
    return _conversions.where((conversion) => conversion.masterId == id).toList();
  }

  List<Conversion> getConversionsByClient(int id) {
    return _conversions.where((conversion) => conversion.clientId == id).toList();
  }

  Conversion getConversion(int clientId, int masterId) {
    for(var c in conversions)
      if(c.clientId == clientId && c.masterId == masterId)
        return c;

    var newConversion = Conversion(Random().nextInt(99999), masterId, clientId, []);
    conversions.add(newConversion);
    return newConversion;
  }

  Conversion getConversionById(int id) {
    return conversions.firstWhere((conversion) => conversion.id == id);
  }

  Message getLastMessageFromConversion(int id) {
    var conversion = getConversionById(id);
    return conversion.messages.first;
  }
}