import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the hall on its dials, the peg on the field, the
/// taps taken, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.wide,
    required this.tall,
    required this.px,
    required this.py,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : wide = Level.openWide,
        tall = Level.openTall,
        px = Level.openX,
        py = Level.openY,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.wide, this.tall, this.px, this.py)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The hall, in paces.
  final int wide, tall;

  /// Where the peg stands.
  final int px, py;

  /// The taps taken.
  final int moves;

  /// The standings tried on the leaning hall.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 14;

  /// The standings a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 4;

  int get lean => level.lean;

  List<int> get squares => Rules.squares(wide, tall, lean, px, py);

  int get acrossOne => Rules.acrossOne(wide, tall, lean, px, py);

  int get acrossTwo => Rules.acrossTwo(wide, tall, lean, px, py);

  int get apart => Rules.apart(wide, tall, lean, px, py);

  bool get agrees => apart == 0;

  bool get inside => Rules.inside(wide, tall, lean, px, py);

  List<(int, int)> get posts => Rules.posts(wide, tall, lean);

  Play _to(int wide, int tall, int px, int py) {
    final nowSeen = !level.winnable
        ? {...seen, '$wide,$tall,$px,$py'}
        : seen;
    return Play._(
      level: level,
      wide: wide,
      tall: tall,
      px: px,
      py: py,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Widens or narrows the hall.
  Play stepWide(int by) {
    final to = wide + by;
    if (isOver || !Rules.validHall(to, tall)) return this;
    return _to(to, tall, px, py);
  }

  /// Lengthens or shortens it.
  Play stepTall(int by) {
    final to = tall + by;
    if (isOver || !Rules.validHall(wide, to)) return this;
    return _to(wide, to, px, py);
  }

  /// Stands the peg on a point of the field.
  Play stand(int x, int y) {
    if (isOver || !Rules.onField(x, y) || (x == px && y == py)) return this;
    return _to(wide, tall, x, y);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(wide, tall, px, py);

  /// A hopeless ask, admitted: [enough] standings tried, or [gaveUpAt]
  /// taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: which dial to step, or where to stand the
  /// peg; null when there is nothing to point at.
  (String, int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (wide != aim.$1) return ('wide', wide < aim.$1 ? 1 : -1, 0);
    if (tall != aim.$2) return ('tall', tall < aim.$2 ? 1 : -1, 0);
    if (px != aim.$3 || py != aim.$4) return ('peg', aim.$3, aim.$4);
    return null;
  }

  /// Does what the pointer says.
  Play follow((String, int, int) aim) => switch (aim.$1) {
        'wide' => stepWide(aim.$2),
        'tall' => stepTall(aim.$2),
        _ => stand(aim.$2, aim.$3),
      };

  /// The pointer's words.
  static String pointed((String, int, int) aim) => switch (aim.$1) {
        'wide' => aim.$2 > 0
            ? 'Widen the hall by a pace.'
            : 'Narrow the hall by a pace.',
        'tall' => aim.$2 > 0
            ? 'Lengthen the hall by a pace.'
            : 'Shorten the hall by a pace.',
        _ => 'Stand the peg at (${aim.$2}, ${aim.$3}).',
      };
}

/// Why the two sums agree: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A hall with a post at each corner, and a peg standing anywhere at '
      'all, inside or out. Square the distance from the peg to each post and '
      'add the opposite pairs: PA squared plus PC squared against PB squared '
      'plus PD squared. They are always the same. It goes by the name of the '
      'British flag theorem, after the four lines from the peg to the '
      'corners.\n\n'
      'The reason is that the two sums are the same expression once the '
      'brackets are multiplied out. Drop a foot from the peg to each wall '
      'and the same two lengths appear in both sums, one on each side of the '
      'hall: what the near wall takes off one pair the far wall gives back '
      'to the other. It needs the corners to be square and nothing else, not '
      'the peg inside, not the hall any particular shape.\n\n'
      'Lean the far wall over and it fails, and by the same amount '
      'everywhere: the two sums part company by twice the lean times the '
      'width, with the peg nowhere in it. That is the fifth ask, and it '
      'cannot be landed.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every hall and every '
      'standing of the peg, 11,025 of them, taken in full before the sham '
      'was built.';
}
