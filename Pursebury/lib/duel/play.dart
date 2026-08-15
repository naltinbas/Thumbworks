import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two purses and the coin, the taps taken to set
/// them, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.ash,
    required this.birch,
    required this.coin,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on three coins to two with the fair coin: no ask is
  /// landed by that, and the checker says so.
  Play.of(this.level)
      : ash = 3,
        birch = 2,
        coin = 1,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.ash, this.birch, this.coin)
      : moves = 0,
        before = null;

  final Level level;
  final int ash;
  final int birch;

  /// The coin: 0 against Ash, 1 fair, 2 for him.
  final int coin;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets to the nearest setting.
  static const gaveUpAt = 30;

  int get pot => ash + birch;

  /// Ash's chance of the pot, by the formula.
  Frac get chance => Rules.chanceByFormula(ash, birch, coin);

  /// The tosses the duel lasts on average, by the formula.
  Frac get lasts => Rules.lastsByFormula(ash, birch, coin);

  /// The whole chain of chances, purse by purse, for the picture.
  List<Frac> get chain => Rules.solveChain(pot, Rules.coins[coin]);

  Play _with({int? ash, int? birch, int? coin}) => Play._(
        level: level,
        ash: ash ?? this.ash,
        birch: birch ?? this.birch,
        coin: coin ?? this.coin,
        moves: moves + 1,
        before: this,
      );

  /// Turns dial [which] (0 Ash's purse, 1 Birch's) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final a = which == 0 ? ash + by.sign : ash;
    final b = which == 1 ? birch + by.sign : birch;
    if (a < 1 || a > Rules.most || b < 1 || b > Rules.most) return this;
    return _with(ash: a, birch: b);
  }

  /// Turns the coin over: against, fair, for, and round again.
  Play turnCoin() => isOver ? this : _with(coin: (coin + 1) % Rules.coins.length);

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(ash, birch, coin);

  /// A hopeless ask, admitted: the player has got to the nearest setting
  /// there is, six coins to one with the coin against him, or has tapped
  /// [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (ash == Rules.most && birch == 1 && coin == 0 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way) with dial 0 Ash, 1 Birch, 2 the
  /// coin (way 0); the coin first, then Ash, then Birch, each towards the
  /// aim; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (coin != aim.$3) return (2, 0);
    if (ash != aim.$1) return (0, (aim.$1 - ash).sign);
    if (birch != aim.$2) return (1, (aim.$2 - birch).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => switch (aim.$1) {
        2 => 'Turn the coin over.',
        0 => '${aim.$2 > 0 ? 'Give' : 'Take'} Ash a coin.',
        _ => '${aim.$2 > 0 ? 'Give' : 'Take'} Birch a coin.',
      };
}

/// Why the share is the chance: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two purses and a coin, tossed for a coin a time until one purse is '
      'empty. With a fair coin Ash takes the whole pot exactly as often as '
      'his share of it: his chance from any purse is the average of his '
      'chances a coin up and a coin down, so it climbs in a straight line from '
      'nothing at an empty purse to everything at the whole pot. With a coin '
      'against him it sags below the line, and with a coin for him it bows '
      'above it: from a purse of a with a pot of a plus b it is 1 less r to '
      'the a over 1 less r to the pot, r the odds against him on a toss. A '
      'fair duel lasts the two purses multiplied, on average.\n\n'
      'The game solves every duel as a chain of purses, the equations '
      'eliminated in exact fractions, as well as taking the formula, and the '
      'two agree on all ${Rules.settings} settings, chance and length both.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every purse of one to six coins '
      'each and the three coins, ${Rules.settings} settings, tried in full.';
}
