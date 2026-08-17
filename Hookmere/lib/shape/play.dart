import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: how the boxes are laid, the moves made, and the go
/// before, so a move can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.rows,
    required this.holding,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : rows = Rules.opening,
        holding = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a staircase, no moves counted: what the mark
  /// draws.
  Play.standing(this.level, this.rows, {this.holding})
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// How long each row is, the longest first.
  final List<int> rows;

  /// The row a box has been lifted from, waiting to be put down.
  final int? holding;

  /// The moves made.
  final int moves;

  /// The staircases tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The moves a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The staircases a hopeless ask lets the player lay before the sham
  /// admits it.
  static const enough = 4;

  /// The fillings, counted one at a time.
  int get counted => Rules.byCounting(rows);

  /// The fillings, worked out from the hooks.
  int get byHooks => Rules.byHooks(rows);

  List<int> get hooks => Rules.hooks(rows);

  int get hookProduct => Rules.hookProduct(rows);

  /// The staircase turned on its side.
  List<int> get turned => Rules.turned(rows);

  bool isCorner(int row) => Rules.corners(rows).contains(row);

  /// Whether the held box can go on row [to], where a row past the last
  /// starts a new one.
  bool canDrop(int to) =>
      holding != null && Rules.move(rows, holding!, to) != null;

  Play _to(List<int> to) {
    final at = to.join(',');
    return Play._(
      level: level,
      rows: to,
      holding: null,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Taps a row: lifts a box off its corner, drops a held box on it, or
  /// puts the held box back.
  Play tap(int row) {
    if (isOver) return this;
    if (holding == null) {
      if (!isCorner(row)) return this;
      return Play._(
        level: level,
        rows: rows,
        holding: row,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    if (holding == row) {
      return Play._(
        level: level,
        rows: rows,
        holding: null,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    final to = Rules.move(rows, holding!, row);
    if (to == null) return this;
    return _to(to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(rows);

  /// A hopeless ask, admitted: [enough] staircases tried, or [gaveUpAt]
  /// moves made.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The moves left to the ask and the move to make first, walked
  /// outward from where the boxes stand.
  (int, (int, int))? get toGo {
    if (level.meets(rows)) return (0, (0, 0));
    final away = <String, int>{rows.join(','): 0};
    final first = <String, (int, int)>{};
    final queue = <List<int>>[rows];
    for (var head = 0; head < queue.length; head++) {
      final at = queue[head];
      final key = at.join(',');
      for (final from in Rules.corners(at)) {
        for (var to = 0; to <= at.length; to++) {
          final next = Rules.move(at, from, to);
          if (next == null) continue;
          final id = next.join(',');
          if (away.containsKey(id)) continue;
          away[id] = away[key]! + 1;
          first[id] = identical(at, rows) ? (from, to) : first[key]!;
          if (level.meets(next)) return (away[id]!, first[id]!);
          queue.add(next);
        }
      }
    }
    return null;
  }

  /// What the pointer says, or null when there is nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final go = toGo;
    return go == null || go.$1 == 0 ? null : go.$2;
  }

  /// The pointer's words, given what the hand is holding.
  static String pointed((int, int) aim, int? holding, int rows) {
    if (holding == null) return 'Lift a box off row ${aim.$1 + 1}.';
    if (holding == aim.$1) {
      return aim.$2 >= rows
          ? 'Start a new row with it.'
          : 'Put it on row ${aim.$2 + 1}.';
    }
    return 'Put the box back on row ${holding + 1}.';
  }
}

/// Why the hooks always give the count: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Eight boxes are laid in a staircase: rows left aligned, each row no '
      'longer than the one above it. A filling numbers the boxes 1 to 8 so '
      'that the numbers rise along every row and down every column. The ask '
      'is how many fillings a staircase has.\n\n'
      'Every box has a hook: the box itself, the boxes to its right in its '
      'row, and the boxes below it in its column. Multiply all eight hooks '
      'together, divide eight factorial by the answer, and that is the number '
      'of fillings. It comes out whole every time, and it is right every '
      'time. Frame, Robinson and Thrall published it in 1954.\n\n'
      'Nothing about it is obvious. The hooks of 4, 2, 1, 1 are 7, 4, 2, 1, '
      '4, 1, 2, 1, which multiply to 448, and 40320 over 448 is 90, the most '
      'fillings any staircase of eight boxes has. Turn a staircase on its '
      'side and the hooks come back in a different order but the same '
      'multiset, so a staircase and its turning always have the same count.\n\n'
      'The sham counts every staircase twice: once by the hooks, which counts '
      'nothing, and once by taking the largest number off a corner and '
      'counting the fillings of what is left, which is the definition worked '
      'out in full. All 22 staircases of eight boxes agree, and so do the 30 '
      'of nine boxes and the 42 of ten.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every staircase counted both '
      'ways before the sham was built.';
}
