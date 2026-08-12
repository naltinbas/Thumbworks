/// The law of the stones.
///
/// Five stones, each showing one to six. A third is three
/// stones whose faces sum to a three-times. Erdos, Ginzburg
/// and Ziv's 1961 law says five stones always carry a third;
/// the sweep of all 7,776 hands says more: the count of thirds
/// only ever lands on one, four or ten, and lands ten exactly
/// when every stone shares one remainder.
class Rules {
  static const stones = 5;
  static const faces = 6;

  /// Every triple of the hand, as index triples.
  static List<(int, int, int)> get triples => [
        for (var a = 0; a < stones; a++)
          for (var b = a + 1; b < stones; b++)
            for (var c = b + 1; c < stones; c++) (a, b, c),
      ];

  /// The thirds of a hand: triples summing to a three-times.
  static List<(int, int, int)> thirds(List<int> hand) => [
        for (final (a, b, c) in triples)
          if ((hand[a] + hand[b] + hand[c]) % 3 == 0) (a, b, c),
      ];

  /// The two-case argument, executed on one hand: either some
  /// remainder shows three times, or all three remainders show.
  static bool twoCases(List<int> hand) {
    final counts = [0, 0, 0];
    for (final face in hand) {
      counts[face % 3]++;
    }
    final thrice = counts.any((count) => count >= 3);
    final allThree = counts.every((count) => count >= 1);
    return thrice || allThree;
  }

  /// Every hand of the yard, walked; calls [visit] with each.
  /// [locked] pins a stone's face. The sweep the checker and
  /// the suite share.
  static void hands(
    void Function(List<int>) visit, {
    (int, int)? locked,
  }) {
    final hand = List.filled(stones, 1);
    void dial(int from) {
      if (from == stones) {
        visit(hand);
        return;
      }
      if (locked != null && locked.$1 == from) {
        hand[from] = locked.$2;
        dial(from + 1);
        return;
      }
      for (var face = 1; face <= faces; face++) {
        hand[from] = face;
        dial(from + 1);
      }
    }

    dial(0);
  }

  /// How many hands carry exactly [asked] thirds.
  static int waysTo(int asked, {(int, int)? locked}) {
    var ways = 0;
    hands((hand) {
      if (thirds(hand).length == asked) ways++;
    }, locked: locked);
    return ways;
  }

  /// The third counts over every hand, spread by count.
  static Map<int, int> spread({(int, int)? locked}) {
    final counts = <int, int>{};
    hands((hand) {
      final held = thirds(hand).length;
      counts[held] = (counts[held] ?? 0) + 1;
    }, locked: locked);
    return counts;
  }

  /// The laws, held over every hand: the count quantised to
  /// one, four or ten, the two-case argument standing, and ten
  /// exactly when one remainder rules. True when nothing breaks.
  static bool lawsHold() {
    var sound = true;
    hands((hand) {
      final held = thirds(hand).length;
      if (held != 1 && held != 4 && held != 10) sound = false;
      if (!twoCases(hand)) sound = false;
      final remainders = {for (final face in hand) face % 3};
      if ((held == 10) != (remainders.length == 1)) sound = false;
    });
    return sound;
  }
}
