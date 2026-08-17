import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: what is in each purse, the taps taken, the full
/// divisions tried that put the long bond ahead, and the go before, so
/// a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.purses,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : purses = const [0, 0, 0],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a division, no taps counted: what the mark draws.
  Play.standing(this.level, this.purses)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The coins in each purse.
  final List<int> purses;

  /// The taps taken.
  final int moves;

  /// The full divisions tried that put the long bond ahead of the
  /// short one.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 20;

  /// The divisions a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 3;

  int get inPurses => purses.reduce((a, b) => a + b);

  /// What is left in the chest.
  int get chest => level.estate - inPurses;

  /// How far out of true each scale hangs, in half coins: AB, BC, CA.
  List<int> get tilts => [
        Rules.tilt(purses, 0, 1),
        Rules.tilt(purses, 1, 2),
        Rules.tilt(purses, 2, 0),
      ];

  bool get allLevel => Rules.allLevel(purses);

  /// Puts [by] coins into purse [which], or takes them out.
  Play step(int which, int by) {
    if (isOver || which < 0 || which >= Rules.heirs || by == 0) return this;
    final to = purses[which] + by;
    if (to < 0 || by > chest) return this;
    final next = List.of(purses)..[which] = to;
    final full = next.reduce((a, b) => a + b) == level.estate;
    final nowSeen = !level.winnable && full && next[2] > next[0]
        ? {...seen, next.join(',')}
        : seen;
    return Play._(
      level: level,
      purses: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(purses);

  /// A hopeless ask, admitted: [enough] full divisions tried with the
  /// long bond ahead, or [gaveUpAt] taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (purse, by), the biggest step towards the
  /// division that levels the scales; null when there is nothing to
  /// point at.
  (int, int)? get next {
    final want = level.aim;
    if (want == null || isOver) return null;
    for (var i = 0; i < Rules.heirs; i++) {
      final gap = want[i] - purses[i];
      if (gap == 0) continue;
      for (final step in [3, 1]) {
        if (gap >= step) return (i, step);
        if (gap <= -step) return (i, -step);
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) {
    final coins = aim.$2.abs() == 1 ? 'a coin' : '${aim.$2.abs()} coins';
    return aim.$2 > 0
        ? 'Put $coins in ${Rules.names[aim.$1]}\'s purse.'
        : 'Take $coins out of ${Rules.names[aim.$1]}\'s purse.';
  }
}

/// Why the three rows are one rule: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two men hold a garment. One claims the whole of it and the other '
      'claims half. The Mishnah, at Bava Metzia 1:1, gives the first three '
      'quarters and the second one quarter: the second has conceded half the '
      'garment already, and only the other half is in dispute, so that half '
      'is split. The rule is the same whatever the claims and whatever there '
      'is to divide. Each side concedes what the estate exceeds the other\'s '
      'claim, and what neither concedes is halved.\n\n'
      'The estate table at Ketubot 93a divides among three widows with bonds '
      'of 100, 200 and 300 zuz. A hundred goes equally, two hundred goes 50, '
      '75 and 75, and three hundred goes 50, 100 and 150. The three rows '
      'look like three different rules: equal shares, then something odd, '
      'then shares in proportion. Robert Aumann and Michael Maschler showed '
      'in 1985 that they are one rule. Each row is the division in which '
      'every pair of heirs splits the coins the two of them hold by the '
      'garment rule, and each is the nucleolus of the bankruptcy game.\n\n'
      'Here the bonds are 12, 24 and 36 coins, the same table at twenty-five '
      'zuz to three coins. The sham hangs a scale between each pair of '
      'purses and tips it by how far that pair is from the garment split. '
      'Level all three at once and the division is the Talmud\'s.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every division of the '
      'estate, tried in full before the sham was built.';
}
