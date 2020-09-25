import 'package:style_app/model/Position.dart';

class PositionsHolder {
  static List<Position> positions = [];
  
  static Position positionById(int id) => positions.firstWhere((p) => p.id == id, orElse: () => null);
  
}