import 'dart:convert';

import 'package:style_app/model/Notification.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/HeadersUtil.dart';

class NotificationRepository {
  static NotificationRepository _instance;

  static NotificationRepository get() {
    if(_instance == null)
      _instance = NotificationRepository();
    return _instance;
  }

  Future<List<Notification>> getNotifications(ProfileProvider profile) async {
    var r = await http.get("$url/notifications/list",
    headers: HeadersUtil.getAuthorizedHeaders(profile.token));
    print("[${r.statusCode}] [${r.body}]");
    var notifications = <Notification> [];
    if(r.statusCode == 200) {
      final decodeData = utf8.decode(r.bodyBytes);
      var b = jsonDecode(decodeData);
      for(var n in b) {
        var notification = Notification.fromJson(n);
        notifications.add(notification);
      }
    }
    return notifications;
  }

}