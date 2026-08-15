import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three dials, the taps taken to set them, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.wine,
    required this.water,
    required this.spoon,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on ten of wine, ten of water and a spoon of one:
  /// no ask is landed by that, and the checker says so.
  Play.of(this.level)
      : wine = 10,
        water = 10,
        spoon = 1,
        moves = 0,
        before = null;

  /// A play stood at a setting, for the mark and the tests.
  Play.standing(this.level, this.wine, this.water, this.spoon)
      : moves = 0,
        before = null;

  final Level level;
  final int wine, water, spoon;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 30;

  bool get pours => Rules.pours(wine, water, spoon);

  /// The pouring, well stirred: (water in the wine, wine in the water).
  (Frac, Frac)? get pouring => Rules.stirred(wine, water, spoon);

  List<int> get dials => [wine, water, spoon];

  /// Turns dial [which] (0 wine, 1 water, 2 spoon) by [by]; a dial at
  /// its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final d = dials;
    d[which] = d[which] + by.sign;
    final top = which == 2 ? Rules.spoonMost : Rules.most;
    if (d[which] < 1 || d[which] > top) return this;
    return Play._(level: level, wine: d[0], water: d[1], spoon: d[2], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(wine, water, spoon);

  /// A hopeless ask, admitted after [gaveUpAt] taps, or when the spoon
  /// is as big as it goes against a glass of one, the wildest pouring
  /// there is, and the two are equal still.
  bool get gaveUp => !level.winnable && (spoon == Rules.spoonMost && water == 1 && pours || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the first dial off the aim
  /// first; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = [aim.$1, aim.$2, aim.$3];
    for (var i = 0; i < 3; i++) {
      if (dials[i] != want[i]) return (i, (want[i] - dials[i]).sign);
    }
    return null;
  }

  static String pointed((int, int) aim) => '${aim.$2 > 0 ? 'More' : 'Less'} ${const ['wine', 'water', 'in the spoon'][aim.$1]}.';
}

/// Why the two are equal: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A glass of wine and a glass of water. Carry a spoon of wine into '
      'the water, then a spoon of whatever is now in the water glass back '
      'into the wine. Is there more water in the wine, or more wine in the '
      'water? Neither, and the stirring does not matter: the wine glass ends '
      'holding just what it began with, so the water in it fills exactly the '
      'room the missing wine left, and every drop of that missing wine is in '
      'the water glass. Well stirred, the spoon back carries spoon times '
      'water over water plus spoon units of water home; unstirred with the '
      'wine afloat it carries the wine straight back; sunk, it carries water; '
      'and the two amounts come out equal every way.\n\n'
      'The game pours every setting of the three dials in exact fractions, '
      '${Rules.settings} settings and three stirs each, and holds every '
      'pouring to the account: equal, every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every glass of one to ten, both, '
      'and every spoon of one to five, tried in full.';
}
