import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.fifths,
    required this.octaves,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : fifths = 0,
        octaves = 0,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.fifths, this.octaves)
      : moves = 0,
        before = null;

  final Level level;
  final int fifths;
  final int octaves;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets to the comma.
  static const gaveUpAt = 40;

  /// The note as it stands, an exact fraction of the start.
  (BigInt, BigInt) get note => Rules.note(fifths, octaves);

  /// The note in cents, the second voice.
  double get cents => Rules.cents(fifths, octaves);

  /// Turns dial [which] (0 the fifths, 1 the octaves) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final f = which == 0 ? fifths + by.sign : fifths;
    final o = which == 1 ? octaves + by.sign : octaves;
    if (f.abs() > Rules.fifths || o.abs() > Rules.octaves) return this;
    return Play._(
      level: level,
      fifths: f,
      octaves: o,
      moves: moves + 1,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(fifths, octaves);

  /// A hopeless ask, admitted: the player has got to the comma, as near
  /// as fifths come, or has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (fifths != 0 && Rules.within(note, 20) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the fifths first, then the
  /// octaves, each towards the aim; null when there is nothing to point
  /// at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (fifths != aim.$1) return (0, (aim.$1 - fifths).sign);
    if (octaves != aim.$2) return (1, (aim.$2 - octaves).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => '${aim.$2 > 0 ? 'Raise' : 'Lower'} the ${aim.$1 == 0 ? 'fifths' : 'octaves'}.';
}

/// Why the coil never closes: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A fifth is three halves of a note, an octave twice it, and the '
      'coil here stacks them: fifths climb the coil 701.96 cents a step, '
      'octaves lift or drop it a whole turn, 1,200 cents. Every note the two '
      'dials reach is 3 to the fifths over 2 to something, an exact fraction, '
      'and the game keeps it as one, rounding only to say the cents.\n\n'
      'Twelve fifths up climb 531,441 over 4,096, seven turns and a hair: '
      'seven octaves down leave 531,441 over 524,288, the comma, 23.46 cents '
      'sharp of home. That hair is why the piano\'s fifths are all a shade '
      'flat, 700 cents to the pure 701.96: it is the comma spread over the '
      'twelve. And no stack of fifths ever comes home, since 3 to any power '
      'is odd and 2 to any power is even.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every setting of the two dials, '
      '${Rules.commas(BigInt.from(Rules.settings))} of them, tried with exact '
      'fractions and held against the cents.';
}
