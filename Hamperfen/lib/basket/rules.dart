/// The law of the fen.
///
/// Sixteen baskets stand on the shelf, one for every mixture of
/// the four herbs, the empty basket and the full one included. A
/// basket swallows another when it holds every herb the other
/// does, and a picking is free when no taken basket swallows a
/// taken basket.
///
/// Sperner's theorem sets the ceiling: four herbs allow six
/// baskets free at most, the six two-herb baskets, and exactly
/// one family of six does it. It is checked more ways than one:
/// the swallow census reads every taken pair; the sweep tries
/// every family; and the shelf arithmetic weighs each basket at
/// six over its shelf's width, a free picking never weighing
/// past six. The suite refuses the bake the moment any two part
/// ways.
class Rules {
  /// Every basket, as a mixture of the four herbs.
  static List<int> get shelfBaskets =>
      [for (var basket = 0; basket < 16; basket++) basket];

  /// How many herbs a basket holds.
  static int herbs(int basket) {
    var held = 0;
    for (var herb = 0; herb < 4; herb++) {
      if ((basket >> herb) & 1 == 1) held++;
    }
    return held;
  }

  /// Whether one basket swallows the other, either way round.
  static bool swallows(int one, int two) =>
      one != two && ((one & two) == one || (one & two) == two);

  /// Every swallowing pair among taken baskets, small then big.
  static List<(int, int)> swallowings(List<int> taken) {
    final found = <(int, int)>[];
    for (var a = 0; a < taken.length; a++) {
      for (var b = a + 1; b < taken.length; b++) {
        if (swallows(taken[a], taken[b])) {
          final small = herbs(taken[a]) <= herbs(taken[b])
              ? taken[a]
              : taken[b];
          final big = small == taken[a] ? taken[b] : taken[a];
          found.add((small, big));
        }
      }
    }
    return found;
  }

  static bool free(List<int> taken) => swallowings(taken).isEmpty;

  /// The shelf widths: how many baskets hold each count of
  /// herbs.
  static int shelfWidth(int held) => const [1, 4, 6, 4, 1][held];

  /// The shelf weights in twelfths: twelve over the width of the
  /// basket's shelf, so the empty and full weigh 12, the singles
  /// and triples 3, the middles 2.
  static int weightTwelfths(int basket) =>
      12 ~/ shelfWidth(herbs(basket));

  /// A picking's weight in twelfths: free pickings never pass
  /// twelve.
  static int weighed(List<int> taken) =>
      taken.fold(0, (sum, basket) => sum + weightTwelfths(basket));

  /// Every family of [count] baskets, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  static void families(
      int count, void Function(List<int>) visit) {
    final picked = <int>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var basket = from; basket < 16; basket++) {
        picked.add(basket);
        walk(basket + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many families of [count] come free.
  static int waysTo(int count) {
    var ways = 0;
    families(count, (family) {
      if (free(family)) ways++;
    });
    return ways;
  }

  /// One free family of [count], or null.
  static List<int>? family(int count) {
    List<int>? found;
    families(count, (picked) {
      if (found == null && free(picked)) {
        found = List.of(picked);
      }
    });
    return found;
  }

  /// Whether the shelf arithmetic holds: every free family
  /// weighs twelve twelfths or fewer, and only the whole middle
  /// shelf, the lone empty basket, or the lone full one weigh
  /// twelve exactly.
  static bool lymHolds() {
    var sound = true;
    for (var count = 1; count <= 7; count++) {
      families(count, (family) {
        if (!free(family)) return;
        final weight = weighed(family);
        if (weight > 12) sound = false;
        if (weight == 12) {
          // Twelve exactly means a whole shelf, no more or less:
          // every basket the same size, the shelf taken entire.
          final size = herbs(family.first);
          final wholeShelf =
              family.every((basket) => herbs(basket) == size) &&
                  family.length == shelfWidth(size);
          if (!wholeShelf) sound = false;
        }
      });
    }
    return sound;
  }
}
