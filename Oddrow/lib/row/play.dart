import 'asking.dart';
import 'rules.dart';

/// A wall being wound. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.asking, this.at, this.moves, this.before);

  factory Play.of(Asking asking) => Play._(asking, 0, 0, null);

  /// A play stood at a row, for the mark and the tests.
  factory Play.standing(Asking asking, int at) =>
      Play._(asking, at, 1, null);

  final Asking asking;

  /// The row the wall stands wound to.
  final int at;

  /// Winds taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless asking admits it.
  static const gaveUpAt = 12;

  List<int> get oddPlaces => Rules.oddPlaces(at);

  int get odds => Rules.oddsByRow(at);

  bool get isDone => moves > 0 && odds == asking.odds;

  bool get gaveUp => !asking.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Winds the wall a row up or down, clamped to it.
  Play windBy(int by) {
    final to = (at + by).clamp(0, Rules.top);
    if (isOver || to == at) return this;
    return Play._(asking, to, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The wind the show-me points at: true for up, on a nearest
  /// landing row; null when none lands.
  bool? get next {
    if (isOver || !asking.winnable) return null;
    int? best;
    for (var row = 0; row <= Rules.top; row++) {
      if (Rules.oddsByRow(row) != asking.odds) continue;
      if (row == at && moves == 0) continue;
      if (best == null || (row - at).abs() < (best - at).abs()) {
        best = row;
      }
    }
    if (best == null || best == at) return null;
    return best > at;
  }
}
