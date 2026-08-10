import 'dart:collection';

import 'yard.dart';

/// Every standing a yard can be in, and how far each is from done.
///
/// Walked outwards from everything-on-the-last, so the number against a
/// standing is the fewest moves there are and not merely one somebody found.
/// Seven stones is two thousand odd standings, which is nothing, and it
/// settles every question the game ever asks: the par, the hint, and the
/// moment a move has cost two.
class Moves {
  Moves(this.stones) {
    _walk();
  }

  final int stones;

  late final List<int> _far;

  int get standings => _far.length;

  /// The fewest moves from a standing to done.
  int from(Standing standing) => _far[standing.key];

  /// The move to make next on a shortest way: (from staddle, to staddle).
  (int, int)? nextFrom(Standing standing) {
    final now = from(standing);
    if (now == 0) return null;
    for (var from = 0; from < 3; from++) {
      for (var to = 0; to < 3; to++) {
        if (!standing.canMove(from, to)) continue;
        if (this.from(standing.move(from, to)) == now - 1) {
          return (from, to);
        }
      }
    }
    return null;
  }

  void _walk() {
    var all = 1;
    for (var stone = 0; stone < stones; stone++) {
      all *= 3;
    }
    _far = List.filled(all, -1);

    final done = Standing(List.filled(stones, 2));
    _far[done.key] = 0;
    final waiting = Queue<int>()..add(done.key);

    while (waiting.isNotEmpty) {
      final key = waiting.removeFirst();
      final standing = Standing.unpack(key, stones);
      final far = _far[key];

      for (var from = 0; from < 3; from++) {
        for (var to = 0; to < 3; to++) {
          if (!standing.canMove(from, to)) continue;
          final next = standing.move(from, to).key;
          if (_far[next] >= 0) continue;
          _far[next] = far + 1;
          waiting.add(next);
        }
      }
    }
  }

  /// The doubling argument, which is the floor and the answer at once.
  ///
  /// To move the biggest of n stones off the first staddle, the n-1 stones
  /// above it must first all stand on one other staddle, which costs at least
  /// what n-1 stones cost. Then the big stone moves at least once. Then the
  /// n-1 must come back on top of it, at least what n-1 stones cost again.
  /// So the fewest for n is at least twice the fewest for n-1, plus one, and
  /// one stone costs one: two to the n, less one.
  static int doublingSays(int stones) => (1 << stones) - 1;
}
