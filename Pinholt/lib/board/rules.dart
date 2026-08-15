/// A hole on the board, x across and y up, 0 to side - 1.
typedef Hole = (int, int);

/// The law of the board.
///
/// Pins in the holes of a five-by-five board, never three in a
/// line. Four pins make a frame when they stand at the corners
/// of a four-sided plot with none of them tucked inside the
/// other three: convex position. Esther Klein saw in 1933 that
/// five pins always hold a frame, whatever the board, and Erdos
/// and Szekeres made a theory of it: the fence round five pins
/// runs through five of them, or four, or three, and each way
/// hands over a frame. Six pins hold three frames at the least.
/// The sweep here sets every placing of four, five and six pins
/// on the board and counts, and the fence says the same.
class Rules {
  Rules(this.side);

  final int side;

  List<Hole> get holes => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) (x, y),
      ];

  /// Twice the signed area of the turn a to b to c: positive for
  /// a left turn, nought for three in a line.
  static int turn(Hole a, Hole b, Hole c) =>
      (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);

  /// Whether some three of the pins stand in a line.
  static bool anyThreeInLine(List<Hole> pins) {
    for (var i = 0; i < pins.length; i++) {
      for (var j = i + 1; j < pins.length; j++) {
        for (var k = j + 1; k < pins.length; k++) {
          if (turn(pins[i], pins[j], pins[k]) == 0) return true;
        }
      }
    }
    return false;
  }

  /// Whether a pin set at [hole] would stand in a line with two
  /// pins already there.
  static bool linesUp(List<Hole> pins, Hole hole) {
    for (var i = 0; i < pins.length; i++) {
      for (var j = i + 1; j < pins.length; j++) {
        if (turn(pins[i], pins[j], hole) == 0) return true;
      }
    }
    return false;
  }

  /// The fence: the pins the boundary runs through, in order
  /// round, by the monotone chain.
  static List<Hole> fence(List<Hole> pins) {
    final sorted = List<Hole>.of(pins)
      ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    if (sorted.length <= 2) return sorted;
    final lower = <Hole>[];
    for (final p in sorted) {
      while (lower.length >= 2 &&
          turn(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }
    final upper = <Hole>[];
    for (final p in sorted.reversed) {
      while (upper.length >= 2 &&
          turn(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }
    return [...lower.sublist(0, lower.length - 1), ...upper.sublist(0, upper.length - 1)];
  }

  /// Whether four pins make a frame: all four on their own fence.
  static bool isFrame(List<Hole> four) => fence(four).length == 4;

  /// Every frame among the pins, as a list of four holes each.
  static List<List<Hole>> frames(List<Hole> pins) {
    final found = <List<Hole>>[];
    for (var a = 0; a < pins.length; a++) {
      for (var b = a + 1; b < pins.length; b++) {
        for (var c = b + 1; c < pins.length; c++) {
          for (var d = c + 1; d < pins.length; d++) {
            final four = [pins[a], pins[b], pins[c], pins[d]];
            if (isFrame(four)) found.add(fence(four));
          }
        }
      }
    }
    return found;
  }

  /// The frame count read off the fence alone, no fours checked:
  /// with four pins, one when the fence runs through all four,
  /// none when it runs through three; with five, five for a fence
  /// of five, three for a fence of four and one for a fence of
  /// three. Null for any other count of pins.
  static int? framesByFence(List<Hole> pins) {
    final round = fence(pins).length;
    if (pins.length == 4) return round == 4 ? 1 : 0;
    if (pins.length == 5) return round == 5 ? 5 : round == 4 ? 3 : 1;
    return null;
  }

  /// The one frame of five pins with a fence of three, built and
  /// not searched: the two pins inside, and the two fence pins on
  /// the same side of the line through them.
  static List<Hole>? lonelyFrame(List<Hole> pins) {
    final round = fence(pins);
    if (pins.length != 5 || round.length != 3) return null;
    final inside = [for (final p in pins) if (!round.contains(p)) p];
    final left = [for (final f in round) if (turn(inside[0], inside[1], f) > 0) f];
    final right = [for (final f in round) if (turn(inside[0], inside[1], f) < 0) f];
    final pair = left.length == 2 ? left : right;
    return [...inside, ...pair];
  }

  /// Walks every placing of [count] pins with no three in a line;
  /// calls [visit] with each.
  void placings(int count, void Function(List<Hole>) visit) {
    final all = holes;
    final pins = <Hole>[];
    void place(int from) {
      if (pins.length == count) {
        visit(pins);
        return;
      }
      for (var i = from; i < all.length; i++) {
        if (linesUp(pins, all[i])) continue;
        pins.add(all[i]);
        place(i + 1);
        pins.removeLast();
      }
    }

    place(0);
  }

  /// How many placings of [count] pins hold exactly [asked]
  /// frames, and how many placings there are at all.
  (int, int) waysBySweep(int count, int asked) {
    var ways = 0, all = 0;
    placings(count, (pins) {
      all++;
      if (frames(pins).length == asked) ways++;
    });
    return (ways, all);
  }

  /// The first placing the sweep finds with exactly [asked]
  /// frames, or null; kept once found, since the sweep of six is
  /// slow enough to notice under a thumb.
  List<Hole>? landing(int count, int asked) {
    final key = '$side:$count:$asked';
    if (_landings.containsKey(key)) return _landings[key];
    List<Hole>? found;
    placings(count, (pins) {
      if (found == null && frames(pins).length == asked) {
        found = List.of(pins);
      }
    });
    _landings[key] = found;
    return found;
  }

  static final _landings = <String, List<Hole>?>{};
}
