import 'package:async/async.dart';
import 'package:style_app/model/Record.dart';

class UserOrdersHolder {
  static AsyncMemoizer memoizer = AsyncMemoizer();
  static List<OrderPreview> orderPreviews = <OrderPreview> [];

  static void clear() {
    orderPreviews.clear();
    memoizer = AsyncMemoizer();
  }
}