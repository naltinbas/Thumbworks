import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials and the side, the taps taken to set
/// them, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.hoop,
    required this.coin,
    required this.inside,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on a hoop of three, a roller of one, outside: no
  /// ask is landed by that, and the checker says so.
  Play.of(this.level)
      : hoop = 3,
        coin = 1,
        inside = false,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.hoop, this.coin, this.inside)
      : moves = 0,
        before = null;

  final Level level;
  final int hoop;
  final int coin;
  final bool inside;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets to the nearest setting.
  static const gaveUpAt = 30;

  bool get fits => Rules.fits(hoop, coin, inside);

  /// The turns a trip makes, by the formula; null when the roller does
  /// not fit.
  (int, int)? get turns => Rules.turns(hoop, coin, inside);

  Play _with({int? hoop, int? coin, bool? inside}) => Play._(
        level: level,
        hoop: hoop ?? this.hoop,
        coin: coin ?? this.coin,
        inside: inside ?? this.inside,
        moves: moves + 1,
        before: this,
      );

  /// Turns dial [which] (0 the hoop, 1 the roller) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final h = which == 0 ? hoop + by.sign : hoop;
    final c = which == 1 ? coin + by.sign : coin;
    if (h < 1 || h > Rules.most || c < 1 || c > Rules.most) return this;
    return _with(hoop: h, coin: c);
  }

  /// Sends the roller round the other side.
  Play flip() => isOver ? this : _with(inside: !inside);

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(hoop, coin, inside);

  /// A hopeless ask, admitted: the player has got to the nearest setting
  /// there is, a hoop of one and a roller of six round the outside, or
  /// has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (hoop == 1 && coin == Rules.most && !inside || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way) with dial 0 the hoop, 1 the
  /// roller, 2 the side (way 0); the side first, then the hoop, then the
  /// roller, each towards the aim; null when there is nothing to point
  /// at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (inside != level.inside) return (2, 0);
    if (hoop != aim.$1) return (0, (aim.$1 - hoop).sign);
    if (coin != aim.$2) return (1, (aim.$2 - coin).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => switch (aim.$1) {
        2 => 'Send it round the other side.',
        0 => '${aim.$2 > 0 ? 'Widen' : 'Narrow'} the hoop.',
        _ => '${aim.$2 > 0 ? 'Widen' : 'Narrow'} the roller.',
      };
}

/// Why the trip is a turn: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Roll a coin once round another of the same size and it turns '
      'twice, not once. Its rim unrolls along the hoop\'s, and the two rims '
      'are the same length, so that is one turn; but the coin has also been '
      'carried once round the hoop, and the carrying turns it once more. '
      'In general the turns are the hoop over the roller for the rim, and '
      'one more for the trip round the outside, or one less for the trip '
      'round the inside, where the carrying goes against the rolling.\n\n'
      'The game rolls every trip as well as working it out: the roller '
      'pivots about its point of contact a hair at a time, thirty-six '
      'thousand pivots to the trip, and the pivots add up to the same turns '
      'as the formula, on every setting that fits.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every hoop and roller of one to '
      'six, round the outside and round the inside, ${Rules.settings} '
      'settings, tried in full.';
}
