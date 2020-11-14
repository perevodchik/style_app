import 'dart:convert';

import 'package:style_app/model/Message.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class SocketController {
  static IOWebSocketChannel channel;
  ProfileProvider profile;
  ConversionProvider conversions;
  static SocketController _instance;

  SocketController(this.profile, this.conversions) {
    _instance = this;
  }
  static SocketController get() {
    return _instance;
  }

  Future<void> init() async {
    if(channel == null || channel.closeCode != null) {
      channel = IOWebSocketChannel.connect(
          "$socketUrl/v1/ws/socket?access_token=${profile.token}");
      channel.stream.listen((message) {
        onReceive(message);
      }, onError: (e) {
        onError(e.toString());
      }, onDone: () {
        onDone();
      });
    } else if(channel.closeCode == null) {
      return;
    }
  }

  Future<void> onReceive(dynamic message) async {
    try {
      var b = jsonDecode(message);
      var m = Message.fromJson(b["map"]);
      print(m.toString());
      conversions.addMessage(m);
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> disconnect() async {
    if(channel == null) return;
    channel.sink.close(status.normalClosure);
    channel.sink.done;
    channel = null;
  }

  Future<void> onError(String error) async {
    print("error $error");
    disconnect();
    init();
  }

  Future<void> onDone() async {
    print("done");
  }

}