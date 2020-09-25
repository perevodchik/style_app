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
  static final List<String> languages = ["Русский", "English", "Українська"];
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