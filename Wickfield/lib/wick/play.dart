import 'rules.dart';
import 'wick.dart';

/// A board being pressed. Presses change nothing here but the lamps and
/// the count: every state is a fresh value, and the one before hangs on
/// for take-back.
class Play {
  Play._(this.wick, this.rules, this.board, this.pressed, this.before);

  Play.of(Wick wick)
      : this._(wick, _rulesFor(wick), wick.lit, 0, null);

  final Wick wick;
  final Rules rules;

  /// The lamps lit now.
  final int board;

  /// Presses made so far.
  final int pressed;

  final Play? before;

  static final _kept = <(int, int), Rules>{};

  static Rules _rulesFor(Wick wick) =>
      _kept[(wick.rows, wick.cols)] ??= Rules(wick.rows, wick.cols);

  bool get isDark => board == 0;

  int get lamps => Rules.weigh(board);

  bool lit(int cell) => board & (1 << cell) != 0;

  /// One press. Any lamp may be pressed at any time; the game never
  /// refuses, it only counts.
  Play press(int cell) {
    if (isDark || cell < 0 || cell >= rules.cells) return this;
    return Play._(wick, rules, rules.press(board, cell), pressed + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest presses that darken the board from here, or null.
  int? get fewestFromHere => rules.fewest(board);

  /// A cell from a lightest press-set from here, or null.
  int? get next {
    final presses = rules.lightest(board);
    if (presses == null || presses == 0) return null;
    var cell = 0;
    while (presses & (1 << cell) == 0) {
      cell++;
    }
    return cell;
  }

  /// The quiet pattern this board falls odd against, or null.
  int? get oddAgainst => rules.oddAgainst(board);
}
