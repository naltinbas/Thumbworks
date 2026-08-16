import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the ticket on the dials, the taps taken, the slips
/// tried from passing tickets, and the go before, so a tap can be taken
/// back.
class Play {
  const Play._({
    required this.level,
    required this.digits,
    required this.moves,
    required this.slips,
    required this.before,
  });

  Play.of(this.level)
      : digits = const [0, 0, 0, 0, 1],
        moves = 0,
        slips = 0,
        before = null;

  /// A go standing at a ticket, no taps counted: what the mark draws.
  Play.standing(this.level, this.digits)
      : moves = 0,
        slips = 0,
        before = null;

  final Level level;

  /// The five digits, left to right.
  final List<int> digits;

  /// The taps taken.
  final int moves;

  /// How many turns were made from a passing ticket: the slips tried.
  final int slips;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never slips three times.
  static const gaveUpAt = 20;

  /// The slips from a passing ticket a hopeless ask lets the player try
  /// before the sham admits it.
  static const enough = 3;

  int get sum => Rules.sum(digits);
  List<int> get adds => Rules.adds(digits);
  bool get passes => Rules.passes(digits);
  List<int> get swapPlaces => Level.swapPlaces(digits);
  List<int> get twinPlaces => Level.twinPlaces(digits);

  /// Whether the last tap was a slip from a passing ticket.
  bool get slipped => before != null && before!.passes && moves > before!.moves;

  /// Turns the dial at [place] by [by], round from 9 to 0 and back.
  Play turn(int place, int by) {
    if (isOver || place < 0 || place >= Rules.places || by == 0) return this;
    final next = List.of(digits)..[place] = (digits[place] + by) % 10;
    return Play._(level: level, digits: next, moves: moves + 1, slips: slips + (passes ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(digits);

  /// A hopeless ask, admitted: [enough] slips tried from passing
  /// tickets, each caught, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (slips >= enough && slipped || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (place, by), the leftmost dial off the aim
  /// turned the shorter way round; null when there is nothing to point
  /// at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < Rules.places; i++) {
      if (digits[i] != aim[i]) {
        final up = (aim[i] - digits[i]) % 10;
        return (i, up <= 5 ? 1 : -1);
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Turn dial ${aim.$1 + 1} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why one slip is always caught: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A ticket of five digits, the last a check digit, and Luhn\'s rule: '
      'from the right, double every second digit, taking nine off a double '
      'past nine, add the lot, and the ticket passes when the sum ends in '
      'nought. Hans Peter Luhn of IBM devised it in 1954, and it sits on '
      'bank cards to this day. One slip of a digit is always caught: in a '
      'plain place the sum moves by the difference of the digits, one to '
      'nine, and in a doubled place the doubling takes the ten digits to 0, '
      '2, 4, 6, 8, 1, 3, 5, 7 and 9, every digit once, so it moves there '
      'too. Two neighbours swapped are caught unless they are 0 and 9, the '
      'one pair that adds alike either way round; and a twin pair 22, 33 or '
      '44 turned to 55, 66 or 77, or back, slips through, since a digit and '
      'its double add alike by ten for 2 and 5, 3 and 6, 4 and 7.\n\n'
      'The game takes every ticket, 100,000, sums each by the doubling and '
      'again by the table of doubles, finds 10,000 passing, one a check '
      'digit for every four, and tries every single slip of a digit on '
      'every passing ticket, 450,000, every swap of unlike neighbours, '
      '36,000, and every turn of a twin pair, 36,000: no slip passes, 800 '
      'swaps do, all of a 0 and a 9, and 2,400 twin turns do, all of the '
      'three kinds, and the table says why.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every ticket, summed in full.';
}
