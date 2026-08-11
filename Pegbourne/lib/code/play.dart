import 'riddle.dart';
import 'rules.dart';

/// A riddle being answered. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.riddle, this.slots, this.moves, this.before);

  Play.of(Riddle riddle)
      : this._(riddle, const [-1, -1, -1, -1], 0, null);

  final Riddle riddle;

  /// The candidate pegs, a colour each or -1 for empty.
  final List<int> slots;

  final int moves;

  final Play? before;

  static final _answers = <String, List<int>>{};

  /// The codes agreeing with every row, swept once and kept.
  List<int> get answers =>
      _answers[riddle.name] ??= Rules.answers(riddle.rows);

  bool get isComplete => !slots.contains(-1);

  int? get candidate =>
      isComplete ? Rules.packed([for (final peg in slots) peg]) : null;

  /// Cycles a slot: empty, then each colour, then empty again.
  Play cycle(int slot) {
    if (isDone || slot < 0 || slot >= Rules.pegs) return this;
    final next = [...slots];
    next[slot] = next[slot] == Rules.colours - 1 ? -1 : next[slot] + 1;
    return Play._(riddle, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// How a row stands against the candidate: null while incomplete,
  /// else whether the marks come out as written.
  bool? rowStands(int at) {
    final code = candidate;
    if (code == null) return null;
    return Rules.agrees(code, riddle.rows[at]);
  }

  /// The rows the candidate contradicts.
  List<int> get broken => [
        for (var at = 0; at < riddle.rows.length; at++)
          if (rowStands(at) == false) at,
      ];

  bool get isDone =>
      isComplete && riddle.winnable && broken.isEmpty;

  /// The mend toward the nearest agreeing code: a slot and the colour
  /// it wants, or null.
  (int, int)? get next {
    if (isDone || answers.isEmpty) return null;
    List<int>? nearest;
    var most = -1;
    for (final answer in answers) {
      var matches = 0;
      for (var slot = 0; slot < Rules.pegs; slot++) {
        if (slots[slot] == Rules.pegAt(answer, slot)) matches++;
      }
      if (matches > most) {
        most = matches;
        nearest = [
          for (var slot = 0; slot < Rules.pegs; slot++)
            Rules.pegAt(answer, slot),
        ];
      }
    }
    for (var slot = 0; slot < Rules.pegs; slot++) {
      if (slots[slot] != nearest![slot]) return (slot, nearest[slot]);
    }
    return null;
  }
}
