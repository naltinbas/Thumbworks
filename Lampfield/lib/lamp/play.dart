import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which lamps are lit, the lamps changed, and the go
/// before, so a change can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.message,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : message = Rules.opening,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a message, no changes counted: what the mark
  /// draws.
  Play.standing(this.level, this.message)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Which lamps are lit, the near end first.
  final List<int> message;

  /// The lamps changed.
  final int moves;

  /// The messages tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The changes a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The messages a hopeless ask lets the player send before the sham
  /// admits it.
  static const enough = 4;

  int get weight => Rules.weight(message);

  int get over9 => Rules.over9(message);

  bool get inCode => Rules.inCode(message);

  int get lit => Rules.lit(message);

  /// Whether the reader gets the message back when lamp [gone] goes
  /// out, counting the lamps from 1.
  bool holds(int gone) => Rules.holds(message, gone);

  /// What the reader makes of the message with lamp [gone] out.
  List<int>? readBack(int gone) => Rules.read(Rules.lost(message, gone));

  /// How many of the eight lamps can go out and still be put back.
  int get mended {
    var out = 0;
    for (var gone = 1; gone <= Rules.lamps; gone++) {
      if (holds(gone)) out++;
    }
    return out;
  }

  Play _to(List<int> to) {
    final at = to.join();
    return Play._(
      level: level,
      message: to,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Lights a dark lamp or puts out a lit one, counting from 1.
  Play tap(int lamp) {
    if (isOver || lamp < 1 || lamp > Rules.lamps) return this;
    return _to([
      for (var i = 0; i < Rules.lamps; i++)
        if (i == lamp - 1) 1 - message[i] else message[i],
    ]);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(message);

  /// A hopeless ask, admitted: [enough] messages tried, or [gaveUpAt]
  /// lamps changed.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every message that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final message in Rules.messages())
            if (level.meets(message)) message,
        ];
      });

  /// The nearest message that lands the ask, and how many lamps away it
  /// is.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final win in winners(level)) {
      final taps = Rules.taps(message, win);
      if (away < 0 || taps < away) {
        away = taps;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// The lamp the pointer says to change, counting from 1; null when
  /// there is nothing to point at.
  int? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    for (var i = 0; i < Rules.lamps; i++) {
      if (message[i] != near.$1[i]) return i + 1;
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int lamp) => message[lamp - 1] == 1
      ? 'Put lamp $lamp out.'
      : 'Light lamp $lamp.';
}

/// Why a lost lamp never loses the message: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Eight lamps stand down the valley and the reader at the far end '
      'sees which are lit. The message is worth the sum of the places of the '
      'lit lamps: lamp 1 is worth 1, lamp 8 is worth 8. A message is in the '
      'code when that sum comes to nothing over nine.\n\n'
      'Now a lamp goes out. The reader sees seven lamps and is not told which '
      'one went, or whether it was lit or dark. Even so the message can be '
      'put back, every time, by arithmetic alone: add up what is left, see '
      'how far short of nothing over nine it falls, and that shortfall says '
      'both whether the lost lamp was lit and where it stood. If the '
      'shortfall is no bigger than the number of lit lamps still showing, a '
      'dark lamp went out with exactly that many lit lamps beyond it; '
      'otherwise a lit lamp went out with a countable number of dark lamps '
      'before it.\n\n'
      'The reason it cannot fail is that no two messages in the code can look '
      'the same with a lamp out. If they did the reader would have a choice '
      'to make and nothing to make it with. Varshamov and Tenengolts '
      'published the code in 1965, and Levenshtein showed the same year that '
      'it mends a lost lamp.\n\n'
      'The sham reads every message twice: once by the arithmetic above, and '
      'once by going through all 256 messages and keeping the ones in the '
      'code that could have left those seven lamps showing, which counts '
      'rather than reasons. The two agree on all 240 readings the code '
      'allows, and the second voice never finds two.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every message sent and every '
      'lamp put out before the sham was built.';
}
