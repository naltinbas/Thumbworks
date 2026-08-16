import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three gates, the taps taken to set them, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.d,
    required this.e,
    required this.f,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on gates at 3, 3 and 3: no ask is landed by that,
  /// and the checker says so.
  Play.of(this.level)
      : d = 3,
        e = 3,
        f = 3,
        moves = 0,
        before = null;

  /// A play stood at three gates, for the mark and the tests.
  Play.standing(this.level, this.d, this.e, this.f)
      : moves = 0,
        before = null;

  final Level level;

  /// The gates: d paces from B along BC, e from C along CA, f from A
  /// along AB.
  final int d, e, f;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if the thirds are
  /// never set.
  static const gaveUpAt = 30;

  bool get meet => Rules.meetByCrossing(d, e, f);
  (int, int) get product => Rules.product(d, e, f);
  (int, int, int) get meetingPoint => Rules.meetingPoint(d, e, f);

  List<int> get gates => [d, e, f];

  /// Sets gate [which] (0 D, 1 E, 2 F) to [at] paces from its corner,
  /// one to eleven; the same again is not a tap.
  Play set(int which, int at) {
    if (isOver || at < 1 || at >= Rules.paces || gates[which] == at) return this;
    final g = gates;
    g[which] = at;
    return Play._(level: level, d: g[0], e: g[1], f: g[2], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(d, e, f);

  /// A hopeless ask, admitted: the thirds are set, either way round, and
  /// the lanes miss; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && ((d == 4 && e == 4 && f == 4) || (d == 8 && e == 8 && f == 8) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (gate, paces), the first gate off the aim;
  /// null when nothing points anywhere.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = [aim.$1, aim.$2, aim.$3];
    for (var i = 0; i < 3; i++) {
      if (gates[i] != want[i]) return (i, want[i]);
    }
    return null;
  }

  static String pointed((int, int) aim) => 'Move gate ${const ['D', 'E', 'F'][aim.$1]} to ${aim.$2} paces from ${const ['B', 'C', 'A'][aim.$1]}.';
}

/// Why the product: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A field with corners A, B and C, a gate on each side, and a lane from '
      'each corner to the gate on the far side. Ceva showed in 1678 when the '
      'three lanes meet at one point: exactly when the three ratios the gates '
      'cut their sides in, BD to DC, CE to EA and AF to FB, multiply to one. '
      'The medians do it, 1 times 1 times 1, and meet a third of the way up '
      'and across; three gates a third along, the same way round, do not, 1:2 '
      'times 1:2 times 1:2 being 1:8.\n\n'
      'The game crosses the lanes from A and B in whole-number arithmetic and '
      'tries the lane from C on the crossing, for every setting of the three '
      'gates at whole paces, ${Rules.settings} of them, and Ceva\'s product '
      'says meet or miss on the same settings, every one: 31 meet, and with '
      'twelve paces to a side every meeting has a gate at a middle.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every setting of the three gates, '
      'tried in full.';
}
