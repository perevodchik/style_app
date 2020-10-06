import 'package:async/async.dart';
import 'package:style_app/model/Conversion.dart';

class ConversionsHolder {
  static List<Conversion> conversions = [];
  static AsyncMemoizer memoizer = AsyncMemoizer();

  static void clear() {
    conversions.clear();
    memoizer = AsyncMemoizer();
  }
}