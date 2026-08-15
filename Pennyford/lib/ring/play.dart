import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.middle,
    required this.ring,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on a middle of two and rings of one, nine round: no
  /// ask is landed by that, and the checker says so.
  Play.of(this.level)
      : middle = 2,
        ring = 1,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.middle, this.ring)
      : moves = 0,
        before = null;

  final Level level;
  final int middle;
  final int ring;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never sets equal coins.
  static const gaveUpAt = 30;

  /// The most ring coins that fit, by the angle.
  int get fit => Rules.mostRound(middle, ring);

  /// The turn to spare once they are set, in degrees.
  double get spare => Rules.spare(middle, ring);

  /// The angle each ring coin takes, in degrees.
  double get each => Rules.span(middle, ring) * 180 / 3.141592653589793;

  /// Turns dial [which] (0 the middle, 1 the ring) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final m = which == 0 ? middle + by.sign : middle;
    final r = which == 1 ? ring + by.sign : ring;
    if (m < 1 || m > Rules.most || r < 1 || r > Rules.most) return this;
    return Play._(
      level: level,
      middle: m,
      ring: r,
      moves: moves + 1,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(middle, ring);

  /// A hopeless ask, admitted: the player has set equal coins, six
  /// exactly and the nearest there is, or has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (middle == ring || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the middle first, then the
  /// ring, each towards the aim; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (middle != aim.$1) return (0, (aim.$1 - middle).sign);
    if (ring != aim.$2) return (1, (aim.$2 - ring).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => '${aim.$2 > 0 ? 'Widen' : 'Narrow'} the ${aim.$1 == 0 ? 'middle coin' : 'ring coins'}.';
}

/// Why six and never seven: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Set a coin touching a middle coin of the same size and the two '
      'centres with the centre of the next coin round make a triangle of '
      'equal sides, so each ring coin takes sixty degrees of the turn as seen '
      'from the middle: six fit exactly, touching all round, and a seventh '
      'never, since seven sixties are more than a turn. A smaller ring coin '
      'takes less, twice the arcsine of its radius over the two radii added, '
      'and as many fit as that goes into a full turn.\n\n'
      'The game works the count both ways, by the angle and by setting the '
      'coins at equal angles and measuring between neighbours, and the two '
      'agree on every setting; six equal coins are the one tie, and it is '
      'decided exactly, a half being a half.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every middle and ring of one to '
      'six, ${Rules.settings} settings, tried in full.';
}
