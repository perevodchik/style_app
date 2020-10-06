import 'package:flutter/widgets.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Message.dart';
import 'package:style_app/service/MastersRepository.dart';

class MessagesProvider extends ChangeNotifier {
  List<Conversion> _conversions = [

  ];
  List<Message> _messages = [
  ];
  Map<Conversion, List<Message>> _data = {};

  Map<Conversion, List<Message>> get data => _data;
  List<Conversion> get conversions => _conversions;
  List<Message> get messages => _messages;

  set conversions(List<Conversion> conversionsList) {
    _conversions = conversionsList;
    notifyListeners();
  }
  set messages(List<Message> conversionsList) {
    _messages = conversionsList;
    notifyListeners();
  }

  void sendMessage(Message message, {bool isNotifyListeners = true}) {
    messages.insertAll(0, [message]);
    if(isNotifyListeners)
      notifyListeners();
  }

  List<Message> getMessagesByConversion(int id) {
    return _messages.where((message) => message.conversionId == id).toList();
  }

  Message getLastMessageFromConversion(int id) {
    return getMessagesByConversion(id).first;
  }
}