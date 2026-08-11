import 'rules.dart';
import 'tray.dart';

/// A tray being shunted. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.tray, this.rules, this.board, this.shunts, this.before);

  Play.of(Tray tray)
      : this._(tray, _rulesFor(tray), tray.tiles, 0, null);

  final Tray tray;
  final Rules rules;

  /// The cells now, row by row, nought for the gap.
  final List<int> board;

  /// Shunts made so far.
  final int shunts;

  final Play? before;

  static final _kept = <(int, int), Rules>{};

  static Rules _rulesFor(Tray tray) =>
      _kept[(tray.rows, tray.cols)] ??= Rules(tray.rows, tray.cols);

  bool get isHome {
    for (var cell = 0; cell < board.length; cell++) {
      if (board[cell] != rules.home[cell]) return false;
    }
    return true;
  }

  int get gap => board.indexOf(0);

  int tileAt(int cell) => board[cell];

  /// Whether the tile at this cell touches the gap.
  bool mayShunt(int cell) =>
      cell >= 0 && cell < board.length && rules.besides(gap).contains(cell);

  /// One shunt. The tray comes back unchanged if the tile is not
  /// beside the gap.
  Play shunt(int cell) {
    if (isHome || !mayShunt(cell)) return this;
    return Play._(
        tray, rules, rules.shunted(board, cell), shunts + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest shunts home from here, or null.
  int? get fewestFromHere => rules.fewest(board);

  /// A cell whose shunt steps one nearer home, or null.
  int? get next => rules.next(board);

  bool get even => rules.even(board);
}
