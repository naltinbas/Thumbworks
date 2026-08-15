/// The law of the plank.
///
/// A plank of pens in a row, sheep at the left end facing right,
/// goats at the right end facing left, and one pen empty between.
/// A beast may step forward into the empty pen, or jump forward
/// over one beast of the other kind into it, and never goes back.
/// The old puzzle asks them to change ends. Lucas counted the
/// moves in 1883: with m sheep and n goats the crossing takes
/// m times n plus m plus n moves, and it takes exactly that
/// however it is done, since every sheep passes every goat by one
/// jump, mn jumps, and the rest of the ground, m plus n pens, is
/// covered by steps. Steps alone never do it: without a jump the
/// order along the plank never changes.
class Rules {
  Rules(this.sheep, this.goats, {this.jumps = true});

  final int sheep;
  final int goats;

  /// Whether jumping is allowed.
  final bool jumps;

  /// The plank as first set: S for sheep, G for goats, _ empty.
  String get start => '${'S' * sheep}_${'G' * goats}';

  /// The plank crossed: goats left, sheep right.
  String get goal => '${'G' * goats}_${'S' * sheep}';

  int get length => sheep + goats + 1;

  /// The moves the arithmetic allows: mn jumps and m + n steps.
  int get movesByArithmetic => sheep * goats + sheep + goats;

  /// The pens whose beast may move: a step into the empty pen, or
  /// a jump over one beast of the other kind into it.
  List<int> movers(String plank) {
    final e = plank.indexOf('_');
    final out = <int>[];
    if (e - 1 >= 0 && plank[e - 1] == 'S') out.add(e - 1);
    if (jumps && e - 2 >= 0 && plank[e - 2] == 'S' && plank[e - 1] == 'G') out.add(e - 2);
    if (e + 1 < plank.length && plank[e + 1] == 'G') out.add(e + 1);
    if (jumps && e + 2 < plank.length && plank[e + 2] == 'G' && plank[e + 1] == 'S') out.add(e + 2);
    return out;
  }

  /// The plank after the beast in [pen] moves into the empty pen.
  String moved(String plank, int pen) {
    final e = plank.indexOf('_');
    final chars = plank.split('');
    chars[e] = chars[pen];
    chars[pen] = '_';
    return chars.join();
  }

  /// Whether a move is a jump: two pens travelled.
  bool isJump(String plank, int pen) => (plank.indexOf('_') - pen).abs() == 2;

  /// Every plank reachable from the start, with the fewest moves to
  /// each and how many ways there are to reach it in that many.
  ({Map<String, int> fewest, Map<String, int> ways}) walk() {
    final fewest = <String, int>{start: 0};
    final ways = <String, int>{start: 1};
    final queue = [start];
    var head = 0;
    while (head < queue.length) {
      final plank = queue[head++];
      for (final pen in movers(plank)) {
        final next = moved(plank, pen);
        if (!fewest.containsKey(next)) {
          fewest[next] = fewest[plank]! + 1;
          ways[next] = ways[plank]!;
          queue.add(next);
        } else if (fewest[next] == fewest[plank]! + 1) {
          ways[next] = ways[next]! + ways[plank]!;
        }
      }
    }
    return (fewest: fewest, ways: ways);
  }

  /// Every complete crossing, as a list of moves (pens), walked;
  /// calls [visit]. Since no beast goes back, the walk is finite.
  void crossings(void Function(List<int>) visit) {
    final moves = <int>[];
    void go(String plank) {
      if (plank == goal) {
        visit(moves);
        return;
      }
      for (final pen in movers(plank)) {
        moves.add(pen);
        go(moved(plank, pen));
        moves.removeLast();
      }
    }

    go(start);
  }

  /// The crossings' lengths, and the jumps and steps in each.
  List<(int, int, int)> crossingShapes() {
    final out = <(int, int, int)>[];
    crossings((moves) {
      var plank = start;
      var jumpCount = 0;
      for (final pen in moves) {
        if (isJump(plank, pen)) jumpCount++;
        plank = moved(plank, pen);
      }
      out.add((moves.length, jumpCount, moves.length - jumpCount));
    });
    return out;
  }

  /// The beasts in order along the plank, empty pen left out.
  static String order(String plank) => plank.replaceAll('_', '');
}
