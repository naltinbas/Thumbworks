import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the side and the diagonal, the taps taken to set
/// them, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.side,
    required this.diagonal,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on a side of one and a diagonal of two: no ask is
  /// landed by that, and the checker says so.
  Play.of(this.level)
      : side = 1,
        diagonal = 2,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.side, this.diagonal)
      : moves = 0,
        before = null;

  final Level level;
  final int side;
  final int diagonal;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never climbs to the top rung.
  static const gaveUpAt = 40;

  int get miss => Rules.miss(side, diagonal);

  double get off => Rules.off(side, diagonal);

  bool get onLadder => Rules.rungs.contains((side, diagonal));

  Play _with(int s, int d) => Play._(
        level: level,
        side: s,
        diagonal: d,
        moves: moves + 1,
        before: this,
      );

  /// Turns dial [which] (0 the side, 1 the diagonal) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final s = which == 0 ? side + by.sign : side;
    final d = which == 1 ? diagonal + by.sign : diagonal;
    if (s < 1 || s > Rules.most || d < 1 || d > Rules.most) return this;
    return _with(s, d);
  }

  /// Climbs the ladder a rung: side plus diagonal, twice the side plus
  /// the diagonal; a rung past the dials is not taken.
  Play climb() {
    if (isOver) return this;
    final (s, d) = Rules.climb(side, diagonal);
    if (s > Rules.most || d > Rules.most) return this;
    return _with(s, d);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(side, diagonal);

  /// A hopeless ask, admitted: the player has climbed to the top rung of
  /// the dials, 70 and 99, the nearest whole diagonal there is here, or
  /// has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && ((side, diagonal) == Rules.rungs.last || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way) with dial 0 the side, 1 the
  /// diagonal, 2 the ladder (way 0): on a rung below the aim, climb;
  /// off the ladder, back to one and one; null when there is nothing to
  /// point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (onLadder && side < aim.$1) return (2, 0);
    if (!onLadder) {
      if (side != 1) return (0, (1 - side).sign);
      if (diagonal != 1) return (1, (1 - diagonal).sign);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => switch (aim.$1) {
        2 => 'Climb the ladder a rung.',
        0 => '${aim.$2 > 0 ? 'Lengthen' : 'Shorten'} the side.',
        _ => '${aim.$2 > 0 ? 'Lengthen' : 'Shorten'} the diagonal.',
      };
}

/// Why the ladder, and why never true: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A square\'s diagonal is its side times the square root of two, and '
      'no whole side has a whole diagonal: the diagonal squared would be twice '
      'the side squared, so even, so the diagonal is even and its square a '
      'multiple of four, so the side squared is even and the side even too, '
      'and halving both gives a smaller pair of the same kind, which cannot go '
      'on for ever. The Greeks climbed a ladder instead: from a side and a '
      'diagonal, the next side is their sum and the next diagonal twice the '
      'side plus the diagonal, and every rung misses a true diagonal by one, '
      'over and under in turn, so the ratios 3/2, 7/5, 17/12, 41/29, 99/70 '
      'close on the root.\n\n'
      'The game sweeps every side and diagonal to ${Rules.most} with whole '
      'numbers, ${Rules.commas(Rules.settings)} pairs, and the misses of one '
      'it finds are exactly the rungs; the algebra turns the miss over at every '
      'rung, and it is checked at every one of the pairs; and the pairs that '
      'come nearer the root than every smaller side are the rungs and no '
      'other.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every side and diagonal of one to '
      '${Rules.most}, ${Rules.commas(Rules.settings)} pairs, tried in full.';
}
