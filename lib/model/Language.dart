import 'package:flutter/cupertino.dart';

class Language {
  int id;
  String name;
  Locale locale;

  Language(this.id, this.name, this.locale);

  @override
  String toString() {
    return 'Language{id: $id, name: $name, locale: $locale}';
  }
}