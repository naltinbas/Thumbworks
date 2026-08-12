import 'dart:math' as math;

import 'green.dart';
import 'rules.dart';

/// A fence being raised. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.green, this.posts, this.closed, this.before);

  factory Play.of(Green green) => Play._(green, const [], false, null);

  final Green green;

  /// The hurdles stood so far, in the order they were set.
  final List<(int, int)> posts;

  /// Whether the last rail has closed the fence.
  final bool closed;

  final Play? before;

  bool get isDone => closed && settles(posts);

  /// Whether a closed run of these hurdles would settle the task.
  bool settles(List<(int, int)> fence) {
    final thirds = green.thirds;
    if (thirds != null) {
      return 3 * Rules.area2(fence) == 2 * thirds;
    }
    final twice = green.area2;
    if (twice != null && Rules.area2(fence) != twice) return false;
    final sheep = green.penned;
    if (sheep != null && Rules.penned(fence) != sheep) return false;
    return true;
  }

  bool maySet((int, int) spot) => !closed && Rules.maySet(posts, spot);

  bool get mayClose => !closed && Rules.mayClose(posts);

  /// One more hurdle.
  Play set((int, int) spot) {
    if (!maySet(spot)) return this;
    return Play._(green, [...posts, spot], false, this);
  }

  /// The closing rail, back to the first hurdle.
  Play close() {
    if (!mayClose) return this;
    return Play._(green, posts, true, this);
  }

  /// One step back: a closed fence opens again, an open one loses
  /// its last hurdle.
  Play get back => before ?? this;

  /// What the closed fence pens, twice over; null while open.
  int? get pens => closed ? Rules.area2(posts) : null;

  /// The crossings the closed fence swallows; null while open.
  int? get swallows => closed ? Rules.penned(posts) : null;

  /// The crossings the closed fence's line walks; null while open.
  int? get walks => closed ? Rules.walked(posts) : null;

  /// A finished fence growing from the standing hurdles, walked out
  /// of every extension shortest first; null when none settles the
  /// task.
  List<(int, int)>? get finished {
    if (closed) return null;
    for (var most = math.max(3, posts.length);
        most <= math.max(5, posts.length);
        most++) {
      final found = Rules.complete(green.size, posts, most, settles);
      if (found != null) return found;
    }
    return null;
  }

  /// The next hurdle of that fence, or null when the fence wants
  /// closing instead.
  (int, int)? nextOf(List<(int, int)> finished) =>
      finished.length > posts.length ? finished[posts.length] : null;
}
