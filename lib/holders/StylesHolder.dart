import 'package:style_app/model/Style.dart';

class StylesHolder {
  static List<Style> styles = [];

  static Style styleById(int id) => styles.firstWhere((s) => s.id == id, orElse: () => null);
}