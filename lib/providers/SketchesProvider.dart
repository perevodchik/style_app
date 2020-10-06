import 'package:flutter/cupertino.dart';
import 'package:style_app/holders/SketchesHolder.dart';
import 'package:style_app/model/Sketch.dart';

class SketchesProvider extends ChangeNotifier {
  List<Sketch> _sketches = [];
  List<Sketch> get sketches => _sketches;

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

  set sketches(List<Sketch> val) {
    _sketches = val;
    notifyListeners();
  }

  void addSketch(Sketch sketch) {
    _sketches.insert(0, sketch);
    notifyListeners();
  }

  List<Sketch> findSketchesByAuthor(int authorId) {
    return sketches.where((sketch) => sketch.masterId == authorId).toList();
  }

  double getMinPrice() {
    double min;
    for(var s in _sketches)
      if(min == null)
        min = s.data.price + 0.0;
      else if(s.data.price < min)
        min = s.data.price + 0.0;
    if(min > 1)
      min -= 1;
    return min;
  }

  double getMaxPrice() {
    double max = 0;
    for(var s in _sketches)
      if(s.data.price > max)
        max = s.data.price + 0.0;
    max += 1;
    return max;
  }

  List<Sketch> getByAuthorId(int id) {
    return sketches.where((sketch) => sketch.masterId == id).toList();
  }
}