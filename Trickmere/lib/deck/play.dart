import 'level.dart';
import 'rules.dart';

/// A hand being laid. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.hidden, this.row, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.hiddenFixed, const [], 0, null);

  /// A play stood at a layout, for the mark and the tests.
  factory Play.standing(Level level, Playcard hidden, List<Playcard> row) => Play._(level, hidden, List.of(row), row.length + 1, null);

  final Level level;

  /// The card hidden, or null while none is.
  final Playcard? hidden;

  /// The cards laid in a row for the partner, in order.
  final List<Playcard> row;

  /// Cards hidden, laid and taken back, counted together.
  final int moves;

  final Play? before;

  bool get fixed => level.hiddenFixed != null;

  bool get full => row.length == 4;

  /// What the partner names from the row, once it is full.
  Playcard? get named => full ? Rules.named(row) : null;

  bool get isDone => hidden != null && full && named == hidden;

  bool get gaveUp => !level.winnable && full && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The cards still on the table, neither hidden nor laid.
  List<Playcard> get onTable => [for (final c in level.hand) if (c != hidden && !row.contains(c)) c];

  bool touches(Playcard c) => !isOver && level.hand.contains(c) && !(fixed && c == hidden);

  /// Taps a card: hides it when none is hidden, unhides the hidden one,
  /// takes a laid card back, or lays a card on the table next.
  Play tap(Playcard c) {
    if (!touches(c)) return this;
    if (c == hidden) return Play._(level, null, row, moves + 1, this);
    if (row.contains(c)) return Play._(level, hidden, [for (final r in row) if (r != c) r], moves + 1, this);
    if (hidden == null) return Play._(level, c, row, moves + 1, this);
    if (full) return this;
    return Play._(level, hidden, [...row, c], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at, from the assistant's rule: ('hide',
  /// card), ('unhide', card), ('lay', card) or ('unlay', card); null
  /// when nothing lands.
  (String, Playcard)? get next {
    if (isOver || !level.winnable) return null;
    final aim = Rules.rule(level.hand, hiddenFixed: level.hiddenFixed);
    if (aim == null) return null;
    final (h, r) = aim;
    if (hidden != null && hidden != h) return ('unhide', hidden!);
    for (var i = 0; i < row.length; i++) {
      if (row[i] != r[i]) return ('unlay', row.last);
    }
    if (hidden == null) return ('hide', h);
    return row.length < 4 ? ('lay', r[row.length]) : null;
  }
}
