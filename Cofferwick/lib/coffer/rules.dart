import 'frac.dart';

/// Three coffers of two coins each, gold or silver, and the chance that
/// a gold coin drawn at random has a gold mate.
class Rules {
  static const coffers = 3, slots = 6;

  /// Every laying of the six coins: bit i of [n] set means coin i gold,
  /// coin i being the i ~/ 2 th coffer's left (even) or right (odd) coin.
  static List<bool> laying(int n) => [for (var i = 0; i < slots; i++) (n >> i) & 1 == 1];

  static int get settings => 1 << slots;

  static int golds(List<bool> coins) => coins.where((g) => g).length;

  /// The coffers with two gold coins, one gold and one silver, and two
  /// silver, in that order.
  static (int, int, int) sorts(List<bool> coins) {
    var gg = 0, gs = 0, ss = 0;
    for (var c = 0; c < coffers; c++) {
      final k = (coins[2 * c] ? 1 : 0) + (coins[2 * c + 1] ? 1 : 0);
      if (k == 2) gg++;
      if (k == 1) gs++;
      if (k == 0) ss++;
    }
    return (gg, gs, ss);
  }

  /// The chance by the draws: pick a coffer, then one of its two coins,
  /// six draws alike; among the draws that come up gold, the share whose
  /// mate is gold too. Null when no coin is gold. The first voice.
  static Frac? chanceByDraws(List<bool> coins) {
    var gold = 0, mateGold = 0;
    for (var c = 0; c < coffers; c++) {
      for (var s = 0; s < 2; s++) {
        if (!coins[2 * c + s]) continue;
        gold++;
        if (coins[2 * c + 1 - s]) mateGold++;
      }
    }
    return gold == 0 ? null : Frac.of(mateGold, gold);
  }

  /// The chance by Bayes: each coffer a third; a gold-gold coffer gives
  /// gold surely and its mate is gold, a mixed coffer gives gold half the
  /// time and its mate never is; so the chance is the gold-gold weight
  /// over the whole gold weight. The second voice.
  static Frac? chanceByBayes(List<bool> coins) {
    final (gg, gs, _) = sorts(coins);
    final third = Frac.of(1, 3), half = Frac.of(1, 2);
    final goldWeight = third * Frac.of(gg) + third * half * Frac.of(gs);
    if (goldWeight == Frac.zero) return null;
    return third * Frac.of(gg) / goldWeight;
  }

  static const cofferNames = ['first', 'second', 'third'];
  static const sideNames = ['left', 'right'];

  /// A coffer told: 'gold and gold', 'gold and silver', 'silver and silver'.
  static String tellCoffer(List<bool> coins, int c) =>
      '${coins[2 * c] ? 'gold' : 'silver'} and ${coins[2 * c + 1] ? 'gold' : 'silver'}';

  /// The chance told: '2/3', '1, certain', '0, never', or 'none, no gold'.
  static String tellChance(Frac? p) =>
      p == null ? 'none, no gold coin to draw' : p == Frac.one ? '1, certain' : p == Frac.zero ? '0, never' : '$p';
}
