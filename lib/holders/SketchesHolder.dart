import 'package:async/async.dart';
import 'package:style_app/model/Sketch.dart';

class SketchesHolder {
  static List<SketchPreview> previews = [];
  static AsyncMemoizer memoizer = AsyncMemoizer();
  static bool isLoading = false;
  static bool hasMore = true;
  static int page = 0;
  static int itemsPerPage = 10;

  static void clear() {
    previews.clear();
    memoizer = AsyncMemoizer();
    isLoading = false;
    hasMore = true;
    page = 0;
  }
}