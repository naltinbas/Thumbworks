/// A lantern's place on the mere, x across and y down.
typedef Spot = (int, int);

/// The law of the mere.
///
/// Lanterns on the mere burn by Conway's rule of 1970: a lit
/// lantern stays lit when two or three of its eight neighbours are
/// lit, and goes out otherwise; an unlit spot lights when exactly
/// three of its neighbours are lit. The picture lies still when
/// nothing changes. Four lights lie still two ways, the block and
/// the tub; five one way, the boat; and three lights never lie
/// still: each needs two lit neighbours, so the three sit in one
/// corner of a square, and the fourth corner has three lit
/// neighbours and lights.
class Rules {
  Rules({this.side = 5});

  /// The mere is a square of spots this many along; the rule is
  /// applied on the whole plane, so a light at the edge counts its
  /// neighbours off the mere as unlit spots that may light.
  final int side;

  List<Spot> get spots => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) (x, y),
      ];

  /// How many of a spot's eight neighbours are lit.
  static int litRound(Set<Spot> lit, Spot spot) {
    var count = 0;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        if (lit.contains((spot.$1 + dx, spot.$2 + dy))) count++;
      }
    }
    return count;
  }

  /// The spots that light next turn, on the whole plane.
  static Set<Spot> births(Set<Spot> lit) {
    final out = <Spot>{};
    for (final (x, y) in lit) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final spot = (x + dx, y + dy);
          if (lit.contains(spot)) continue;
          if (litRound(lit, spot) == 3) out.add(spot);
        }
      }
    }
    return out;
  }

  /// The lit spots that go out next turn.
  static Set<Spot> deaths(Set<Spot> lit) => {
        for (final spot in lit)
          if (litRound(lit, spot) != 2 && litRound(lit, spot) != 3) spot,
      };

  /// The picture next turn.
  static Set<Spot> next(Set<Spot> lit) => {...lit}..removeAll(deaths(lit))..addAll(births(lit));

  /// Whether the picture lies still: nothing lights, nothing goes out.
  static bool still(Set<Spot> lit) => lit.isNotEmpty && births(lit).isEmpty && deaths(lit).isEmpty;

  /// Walks every lighting of exactly [count] spots on the mere;
  /// calls [visit].
  void lightings(int count, void Function(Set<Spot>) visit) {
    final all = spots;
    final lit = <Spot>{};
    void pick(int from) {
      if (lit.length == count) {
        visit(lit);
        return;
      }
      for (var i = from; i < all.length; i++) {
        if (all.length - i < count - lit.length) break;
        lit.add(all[i]);
        pick(i + 1);
        lit.remove(all[i]);
      }
    }

    pick(0);
  }

  /// How many lightings of [count] lie still, and how many shapes
  /// they make up to sliding.
  (int, int) sweep(int count) {
    var ways = 0;
    final shapes = <String>{};
    lightings(count, (lit) {
      if (!still(lit)) return;
      ways++;
      shapes.add(shapeOf(lit));
    });
    return (ways, shapes.length);
  }

  /// A lighting slid to the top-left corner, as a string.
  static String shapeOf(Set<Spot> lit) {
    var mx = 1 << 20, my = 1 << 20;
    for (final (x, y) in lit) {
      if (x < mx) mx = x;
      if (y < my) my = y;
    }
    final slid = [for (final (x, y) in lit) '${x - mx},${y - my}']..sort();
    return slid.join(';');
  }

  /// The first still lighting of [count] the sweep finds, or null.
  Set<Spot>? landing(int count) {
    Set<Spot>? found;
    lightings(count, (lit) {
      if (found == null && still(lit)) found = Set.of(lit);
    });
    return found;
  }
}
