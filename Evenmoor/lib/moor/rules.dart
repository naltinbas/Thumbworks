/// A hole on the moor, x across and y down.
typedef Peg = (int, int);

/// The law of the moor.
///
/// Holes in rows across the moor, pegs set in some of them, and a
/// post driven halfway between every two pegs. The post lands on a
/// hole exactly when the two pegs agree in evenness both ways, across
/// and down, since halfway between two whole numbers is whole only
/// when they are both even or both odd. There are but four kinds of
/// hole by evenness, so five pegs must put two in one kind, and their
/// halfway post lands on a hole: the pigeonhole law, and the sweep of
/// all 53,130 placings of five on the moor finds no placing free of
/// it. Four pegs can keep every post off, one to a kind, 1,296 ways.
class Rules {
  Rules({this.side = 5});

  final int side;

  List<Peg> get holes => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) (x, y),
      ];

  /// The kind of a hole by evenness: 0 to 3, across even or odd and
  /// down even or odd.
  static int kindOf(Peg p) => (p.$1 % 2) + 2 * (p.$2 % 2);

  /// Whether the halfway post between two pegs lands on a hole.
  static bool halfwayOnHole(Peg a, Peg b) => (a.$1 + b.$1).isEven && (a.$2 + b.$2).isEven;

  /// The pairs whose halfway post lands on a hole, as index pairs.
  static List<(int, int)> halfwayPairs(List<Peg> pegs) => [
        for (var i = 0; i < pegs.length; i++)
          for (var j = i + 1; j < pegs.length; j++)
            if (halfwayOnHole(pegs[i], pegs[j])) (i, j),
      ];

  /// The halfway post itself, doubled to stay whole.
  static (int, int) postDoubled(Peg a, Peg b) => (a.$1 + b.$1, a.$2 + b.$2);

  /// How many posts land on holes, counted by the pigeonholes: pegs
  /// of a kind pair off two by two, and no other pair lands.
  static int landedByKinds(List<Peg> pegs) {
    final counts = [0, 0, 0, 0];
    for (final peg in pegs) {
      counts[kindOf(peg)]++;
    }
    var landed = 0;
    for (final n in counts) {
      landed += n * (n - 1) ~/ 2;
    }
    return landed;
  }

  /// How many kinds the pegs use.
  static int kindsUsed(List<Peg> pegs) => pegs.map(kindOf).toSet().length;

  /// Every placing of [count] pegs on the moor; calls [visit].
  void placings(int count, void Function(List<Peg>) visit) {
    final all = holes;
    final pegs = <Peg>[];
    void pick(int from) {
      if (pegs.length == count) {
        visit(pegs);
        return;
      }
      for (var i = from; i < all.length; i++) {
        if (all.length - i < count - pegs.length) break;
        pegs.add(all[i]);
        pick(i + 1);
        pegs.removeLast();
      }
    }

    pick(0);
  }

  /// How many placings of [count] pegs land exactly [asked] posts,
  /// and how many placings there are.
  (int, int) sweep(int count, int asked) {
    var ways = 0, all = 0;
    placings(count, (pegs) {
      all++;
      if (halfwayPairs(pegs).length == asked) ways++;
    });
    return (ways, all);
  }

  /// The first placing the sweep finds with exactly [asked] posts
  /// landed, or null.
  List<Peg>? landing(int count, int asked) {
    List<Peg>? found;
    placings(count, (pegs) {
      if (found == null && halfwayPairs(pegs).length == asked) found = List.of(pegs);
    });
    return found;
  }
}
