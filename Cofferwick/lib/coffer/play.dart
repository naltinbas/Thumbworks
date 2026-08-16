import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the six coins, the taps taken to lay them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.coins,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : coins = List.filled(Rules.slots, false),
        moves = 0,
        before = null;

  /// A go standing at a laying, no taps counted: what the mark draws.
  Play.standing(this.level, this.coins)
      : moves = 0,
        before = null;

  final Level level;

  /// The six coins, true for gold: coffer by coffer, left then right.
  final List<bool> coins;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never lays three gold coins.
  static const gaveUpAt = 12;

  int get golds => Rules.golds(coins);
  (int, int, int) get sorts => Rules.sorts(coins);

  /// The chance by the draws, the first voice.
  Frac? get chance => Rules.chanceByDraws(coins);

  /// The chance by Bayes, the second voice.
  Frac? get chanceByBayes => Rules.chanceByBayes(coins);

  /// Turns coin [i] over, gold to silver or silver to gold.
  Play tap(int i) {
    if (isOver || i < 0 || i >= Rules.slots) return this;
    final c = List.of(coins);
    c[i] = !c[i];
    return Play._(level: level, coins: c, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(coins);

  /// A hopeless ask, admitted: three gold coins are laid, and the chance
  /// is what it must be, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (golds == level.golds || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the first coin that differs from the aim,
  /// or null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < Rules.slots; i++) {
      if (coins[i] != aim[i]) return i;
    }
    return null;
  }

  /// The pointer's words.
  static String pointed(int i) => 'Turn the ${Rules.sideNames[i % 2]} coin of the ${Rules.cofferNames[i ~/ 2]} coffer.';
}

/// Why the coins say two thirds: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Three coffers, two coins in each: one holds two gold, one two '
      'silver, one a gold and a silver. Pick a coffer at random, take out a '
      'coin at random, and it is gold: what is the chance its mate is gold? '
      'Bertrand set the puzzle in 1889, and the ready answer, a half, since '
      'the coffer is one of two, is wrong. The draw picks a coin, not a '
      'coffer: three gold coins might have come out, and two of them, the '
      'pair, have a gold mate. Two in three.\n\n'
      'The game lays the six coins every way, ${Rules.settings} layings, and '
      'works each chance twice: by the six draws, a coffer then a coin, all '
      'alike, counting the gold draws whose mate is gold; and by Bayes, each '
      'coffer weighing a third, a gold pair giving gold surely and a mixed '
      'coffer half the time. The two agree on all ${Rules.settings}, and the '
      'chances that come are 0, 1/2, 2/3, 4/5 and 1, nothing else.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every laying of the six coins, '
      'drawn out in full.';
}
