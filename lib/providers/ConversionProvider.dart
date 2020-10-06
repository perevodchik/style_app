
import 'package:flutter/cupertino.dart';
import 'package:style_app/holders/ConversionsHolder.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Message.dart';

class ConversionProvider extends ChangeNotifier {
  List<Conversion> get conversions => ConversionsHolder.conversions;

  set conversions(List<Conversion> newConversions) {
    ConversionsHolder.conversions = newConversions;
    notifyListeners();
  }

  void updateConversion(Conversion conversion) {
    notifyListeners();
  }

  void sendMessage(Conversion conversion, Message message) {
    conversion.messages.insert(0, message);
    notifyListeners();
  }

  Conversion getConversionById(int id) {
    return ConversionsHolder.conversions.firstWhere((conversion) => conversion.id == id);
  }

  void addMessage(Message m) {
    var conversion = conversions.firstWhere((c) => c.id == m.conversionId, orElse: null);
    if(conversion == null) return;
    conversion.messages.insert(0, m);
    conversion.lastMessage = m;
    if(conversion.isRead)
      conversion.isRead = false;
    notifyListeners();
  }
}