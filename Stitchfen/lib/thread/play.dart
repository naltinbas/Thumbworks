import 'row.dart';
import 'rules.dart';

/// A row being threaded. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.row, this.rules, this.threads, this.moves, this.before);

  factory Play.of(Row row) => Play._(
        row,
        Rules(row.stitches),
        [
          ...row.fixed,
          for (var at = row.fixed.length; at < row.stitches; at++)
            'R',
        ],
        0,
        null,
      );

  /// A play stood at a threading, for the mark and the tests.
  factory Play.standing(Row row, List<String> threads) =>
      Play._(row, Rules(row.stitches), List.of(threads), 0, null);

  final Row row;
  final Rules rules;

  /// Every stitch's thread as it stands.
  final List<String> threads;

  /// Flips taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless row admits it.
  static const gaveUpAt = 12;

  List<(int, int)> get ladders => rules.ladders(threads);

  bool get isDone => ladders.isEmpty;

  bool get gaveUp => !row.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a stitch is the player's to flip.
  bool canFlip(int stitch) => stitch >= row.fixed.length;

  /// Flips a stitch to the other thread.
  Play tapAt(int stitch) {
    if (isOver || !canFlip(stitch)) return this;
    final next = List.of(threads);
    next[stitch] = next[stitch] == 'R' ? 'B' : 'R';
    return Play._(row, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The stitch the sweep would flip next towards a ladder-free
  /// row, with the thread it wants; null when none exists.
  (int, String)? get next {
    final aim = rules.threading(row.fixed);
    if (aim == null || isDone) return null;
    for (var at = row.fixed.length; at < row.stitches; at++) {
      if (threads[at] != aim[at]) return (at, aim[at]);
    }
    return null;
  }
}
