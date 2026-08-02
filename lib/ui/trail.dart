import 'dart:collection';

import '../sim/world.dart';

/// The last stretch of the craft's path, kept by the view.
///
/// The simulation has no memory of where the craft has been and does not need
/// one, so this is the view's own record. It is filled one point per fixed
/// step rather than one per frame, which is what stops the streak getting
/// longer on a phone that draws faster.
class Trail {
  Trail({this.capacity = 96});

  /// How many steps of path to keep. At a hundred and twenty steps a second
  /// this is a little under a second of flight, which is long enough to show
  /// the whip round a well and short enough not to draw the whole run.
  final int capacity;

  final List<Vec> _points = <Vec>[];
  int _revision = 0;

  /// Changes whenever the path does. The painter compares this rather than
  /// the points, because the list it draws is the same object every frame.
  int get revision => _revision;

  int get length => _points.length;
  bool get isEmpty => _points.isEmpty;

  /// Oldest first, which is the order it gets drawn in. A view onto the real
  /// list rather than a copy, because this is read every frame.
  late final List<Vec> points = UnmodifiableListView(_points);

  void add(Vec at) {
    _points.add(at);
    if (_points.length > capacity) _points.removeAt(0);
    _revision++;
  }

  /// Drop the oldest point. A run that has ended stops adding and starts
  /// doing this, so the streak is drawn back into the wreck instead of
  /// hanging on screen unchanged.
  void fade() {
    if (_points.isEmpty) return;
    _points.removeAt(0);
    _revision++;
  }

  void clear() {
    if (_points.isEmpty) return;
    _points.clear();
    _revision++;
  }
}
