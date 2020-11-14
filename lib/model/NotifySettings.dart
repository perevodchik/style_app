import 'dart:ui';

import 'package:style_app/model/Language.dart';

class AppSettings {
  bool newOrderNotify = true;
  bool cancelOrderNotify = true;
  bool changeOrderNotify = true;
  int language = 0;
}

class ProfileSettings {
  String name;
  String surname;
  String phone;
  String email;
  int city;
}

class Languages {
  static final List<Language> languages = [
    Language(
      0,
      "Русский",
      Locale("ru", "RU")
    ),
    Language(
        1,
        "English",
        Locale("en", "EN")
    ),
    Language(
        2,
        "Українська",
        Locale("uk", "UA")
    )
    // "Русский",
    // "English",
    // "Українська"
  ];

  static Language byId(int id) {
    return languages.firstWhere((element) => element.id == id, orElse: () => languages.isNotEmpty ? languages.first : Language(
        2,
        "Українська",
        Locale("uk", "UA")
    ));
  }
}

class Cities {
  static final List<String> cities = [
    "Ужгород",
    "Мукачево",
    "Иршава",
    "Хуст",
    "Свалява",
    "Киев",
    "Львов",
    "Миколаев",
    "Харьков",
    "Одесса",
    "Борщев",
    "Житомир"];
}