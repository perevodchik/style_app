import 'package:flutter/cupertino.dart';
import 'package:style_app/holders/SketchesHolder.dart';
import 'package:style_app/model/Sketch.dart';

class SketchesProvider extends ChangeNotifier {
  List<SketchPreview> get previews => SketchesHolder.previews;
  set previews(List<SketchPreview> val) {
    SketchesHolder.previews = val;
    notifyListeners();
  }
  void addSketchPreview(SketchPreview val) {
    SketchesHolder.previews.add(val);
    notifyListeners();
  }
  void setPreviews(List<SketchPreview> val) {
    SketchesHolder.previews.clear();
    SketchesHolder.previews.addAll(val);
    notifyListeners();
  }
  void removeSketch(Sketch sketch) {
    for(var s in previews)
      if(s.id == sketch.id) {
        previews.remove(s);
        notifyListeners();
        return;
      }
  }
}