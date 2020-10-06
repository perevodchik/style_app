import 'package:async/async.dart';
import 'package:style_app/model/Record.dart';

class OrdersHolder {
  static AsyncMemoizer memoizer = AsyncMemoizer();
  static List<OrderAvailablePreview> availables = [];
  static int page = 0;
  static final int itemsPerPage = 10;
  static bool isLoading = false;
  static bool isFirstLoad = false;
  static bool hasMore = true;
}