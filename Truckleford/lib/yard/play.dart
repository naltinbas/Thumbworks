import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the wagons stand, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  Play._({
    required this.level,
    required this.line,
    required this.siding,
    required this.out,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : line = [for (var w = 1; w <= Rules.wagons; w++) w],
        siding = const [],
        out = const [],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a yard, no taps counted: what the mark draws.
  Play.standing(this.level, this.line, this.siding, this.out)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The wagons still on the main line, the head of the train first.
  final List<int> line;

  /// The wagons on the siding, the one at the points last.
  final List<int> siding;

  /// The wagons already sent out, in the order they went.
  final List<int> out;

  /// The taps taken.
  final int moves;

  /// The yards tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The yards a hopeless ask lets the player make before the sham
  /// admits it.
  static const enough = 4;

  String get key => '${line.join(',')}|${siding.join(',')}|${out.join(',')}';

  bool get isClear => out.length == Rules.wagons;

  bool get canShunt => line.isNotEmpty && !isOver;
  bool get canRoll => line.isNotEmpty && !isOver;
  bool get canSend => siding.isNotEmpty && !isOver;

  Play _to(List<int> line, List<int> siding, List<int> out) {
    final at = '${line.join(',')}|${siding.join(',')}|${out.join(',')}';
    return Play._(
      level: level,
      line: line,
      siding: siding,
      out: out,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Shunts the wagon at the head of the line onto the siding, rolls it
  /// straight out, or sends the wagon at the points out.
  Play tap(String what) {
    if (isOver) return this;
    switch (what) {
      case Rules.shunt:
        if (line.isEmpty) return this;
        return _to(line.sublist(1), [...siding, line.first], out);
      case Rules.roll:
        if (line.isEmpty) return this;
        return _to(line.sublist(1), siding, [...out, line.first]);
      case Rules.send:
        if (siding.isEmpty) return this;
        return _to(line, siding.sublist(0, siding.length - 1),
            [...out, siding.last]);
      default:
        return this;
    }
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && isClear && level.meets(out);

  /// The fewest taps from here to an out-train that lands the ask, or
  /// null when no run of the yard can land it any more.
  int? get least => _least(line, siding, out, <String, int?>{});

  int? _least(List<int> line, List<int> siding, List<int> out,
      Map<String, int?> held) {
    if (!level.couldStill(out)) return null;
    if (out.length == Rules.wagons) return level.meets(out) ? 0 : null;
    final at = '${line.join(',')}|${siding.join(',')}|${out.join(',')}';
    if (held.containsKey(at)) return held[at];
    held[at] = null;
    int? best;
    void weigh(int? more) {
      if (more == null) return;
      if (best == null || more + 1 < best!) best = more + 1;
    }

    if (line.isNotEmpty) {
      weigh(_least(line.sublist(1), [...siding, line.first], out, held));
      weigh(_least(line.sublist(1), siding, [...out, line.first], held));
    }
    if (siding.isNotEmpty) {
      weigh(_least(line, siding.sublist(0, siding.length - 1),
          [...out, siding.last], held));
    }
    held[at] = best;
    return best;
  }

  /// A go the ask can no longer be landed from.
  bool get wedged => level.winnable && !isDone && least == null;

  /// A hopeless ask, admitted: [enough] yards tried, or [gaveUpAt] taps
  /// gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp || wedged;

  /// What the pointer says: the tap to take, or null when there is
  /// nothing to point at.
  String? get next {
    if (isOver) return null;
    final away = least;
    if (away == null || away == 0) return null;
    for (final what in [Rules.roll, Rules.send, Rules.shunt]) {
      final then = tap(what);
      if (identical(then, this)) continue;
      if (then._least(then.line, then.siding, then.out, <String, int?>{}) ==
          away - 1) {
        return what;
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed(String what) => switch (what) {
        Rules.shunt => 'Shunt the wagon at the head onto the siding.',
        Rules.roll => 'Roll the wagon at the head straight out.',
        _ => 'Send the wagon at the points out.',
      };
}

/// Why the siding cannot make every order: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Six wagons stand on the main line in the order 1 to 6 and leave by '
      'the far end. A wagon can roll straight past the siding or be shunted '
      'onto it, and a wagon on the siding can be sent out, but only the one '
      'at the points, which is the last one shunted. Everything on the siding '
      'behind it has to wait.\n\n'
      'That last-in first-out rule is the whole of it. Suppose some wagon a '
      'leaves, and later a smaller wagon c leaves, and later still a wagon b '
      'that lies between them. When a left, both b and c were still to come, '
      'and both were smaller than a, so both had already been shunted onto '
      'the siding, c before b since they were shunted in the order they '
      'stand and c is the smaller number. That puts b nearer the points than '
      'c, and only the wagon at the points can be sent, so b has to leave '
      'before c. But the out-train has c leaving first, which the yard cannot '
      'do. So no out-train holds a wagon, then a smaller one, then one in '
      'between: no train of the shape 3, 1, 2.\n\n'
      'Every other order the siding can make. Of the 720 orders of six '
      'wagons, 132 are free of that shape and the yard makes all 132; the '
      'other 588 hold it somewhere and the yard makes none of them. Donald '
      'Knuth set this down in 1968, in the first volume of The Art of '
      'Computer Programming, and the counts for one wagon up to eight are 1, '
      '2, 5, 14, 42, 132, 429, 1430, the Catalan numbers.\n\n'
      'The sham reads every order twice: once by running it through the yard '
      'wagon by wagon, and once by looking for the shape, which never touches '
      'a yard.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every order of every train '
      'up to eight wagons, run in full before the sham was built.';
}
