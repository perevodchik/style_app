import 'package:async/async.dart';
import 'package:style_app/model/MasterData.dart';

class UsersHolder {
  static AsyncMemoizer memoizer = AsyncMemoizer();
  static List<UserShortData> users = [];
  static bool isLoading = false;
  static bool isFirstLoad = false;
  static bool hasMore = true;
  static int page = 0;
  static int itemsPerPage = 10;

  static void clear() {
    users.clear();
    memoizer = AsyncMemoizer();
    isLoading = false;
    isFirstLoad = false;
    hasMore = true;
    page = 0;
  }
}