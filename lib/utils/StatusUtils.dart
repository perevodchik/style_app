import 'package:flutter_i18n/flutter_i18n.dart';

class StatusUtils {
  static String getStatus(context, int status) {
    if(status == 0)
      return FlutterI18n.translate(context, "status0");
      // return "В ожидании";
    else if(status == 1)
      return FlutterI18n.translate(context, "status1");
      // return "Завершен";
    else if(status == 2)
      return FlutterI18n.translate(context, "status2");
      // return "В процессе";
    else if(status == 3)
      return FlutterI18n.translate(context, "status3");
      // return "Ожидает подтверждения";
    else if(status == 4)
      return FlutterI18n.translate(context, "status4");
      // return "Отменен";
    return "---";
  }
}