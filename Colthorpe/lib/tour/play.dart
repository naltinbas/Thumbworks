import 'fewest.dart';
import 'yard.dart';

/// A round part ridden: the path so far, in order.
class Play {
  const Play._(this.yard, this.path);

  Play.of(Yard yard) : this._(yard, const []);

  final Yard yard;

  /// The paddocks ridden, first to last.
  final List<int> path;

  bool get started => path.isNotEmpty;

  bool ridden(int paddock) => path.contains(paddock);

  int? get here => path.isEmpty ? null : path.last;

  /// Every paddock ridden, and home a jump away when the yard asks it.
  bool get isDone {
    if (path.length != yard.paddocks) return false;
    return !yard.closed || Rounds.from(yard, path.last).contains(path.first);
  }

  /// Whether the round can still be finished from here. True before the
  /// first jump only when the yard is possible at all.
  bool get canStillRide {
    if (path.isEmpty) return Rounds.exists(yard);
    return Rounds.canStillRide(yard, path);
  }

  /// Whether the colt may go there next.
  bool mayRide(int paddock) {
    if (paddock < 0 || paddock >= yard.paddocks || ridden(paddock)) {
      return false;
    }
    if (path.isEmpty) {
      return yard.starts == null || paddock == yard.starts;
    }
    return Rounds.from(yard, path.last).contains(paddock);
  }

  /// The jump. Returns this unchanged when the colt cannot make it.
  Play ride(int paddock) {
    if (!mayRide(paddock)) return this;
    return Play._(yard, [...path, paddock]);
  }

  /// The last jump back, or this before the first.
  Play get back =>
      path.isEmpty ? this : Play._(yard, path.sublist(0, path.length - 1));

  /// A jump that keeps the round alive, fewest onward ways first, or null
  /// when there is none or the round is done.
  int? get next {
    if (isDone || !canStillRide) return null;
    if (path.isEmpty) {
      if (yard.starts != null) return yard.starts;
      for (var paddock = 0; paddock < yard.paddocks; paddock++) {
        if (Rounds.canStillRide(yard, [paddock])) return paddock;
      }
      return null;
    }
    final nexts = [
      for (final near in Rounds.from(yard, path.last))
        if (!ridden(near)) near,
    ]..sort((a, b) => _ways(a).compareTo(_ways(b)));
    for (final near in nexts) {
      if (Rounds.canStillRide(yard, [...path, near])) return near;
    }
    return null;
  }

  int _ways(int paddock) {
    var ways = 0;
    for (final near in Rounds.from(yard, paddock)) {
      if (!ridden(near)) ways++;
    }
    return ways;
  }
}
