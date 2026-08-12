import 'field.dart';
import 'rules.dart';

/// A marsh being stepped. Every state is a fresh value, and the one
/// before hangs on for take-back; the solve behind the mere is
/// shared down the line.
class Play {
  Play._(this.field, this.rules, this.cells, this.moves, this.pieOpen,
      this.swapped, this.before);

  factory Play.of(Field field) {
    final rules = Rules(field.size);
    final cells = List<int>.filled(field.size * field.size, 0);
    final opens = field.houseOpens;
    if (opens != null) cells[opens] = 2;
    return Play._(field, rules, cells, 0,
        opens != null && field.pieOffered, false, null);
  }

  final Field field;
  final Rules rules;

  /// The marsh: 0 open, 1 gold, 2 the mere's rushes.
  final List<int> cells;

  /// Your steps taken.
  final int moves;

  /// Whether the pie is on the table right now.
  final bool pieOpen;

  /// Whether the opening was taken for your own.
  final bool swapped;

  final Play? before;

  bool get isDone => rules.crosses(cells, 1);

  bool get isLost => rules.crosses(cells, 2);

  bool get isOver => isDone || isLost;

  /// Take the pie: the opening stone is claimed as your own, laid
  /// across the diagonal where a west-east opening would sit.
  Play takePie() {
    if (!pieOpen) return this;
    final opened = field.houseOpens!;
    final row = opened ~/ field.size;
    final col = opened % field.size;
    final claimed = List.of(cells);
    claimed[opened] = 0;
    claimed[col * field.size + row] = 1;
    final next =
        Play._(field, rules, claimed, moves, false, true, this);
    return next._houseSteps();
  }

  /// Wave the pie by and step on.
  Play declinePie() {
    if (!pieOpen) return this;
    return Play._(field, rules, List.of(cells), moves, false, false,
        this);
  }

  bool mayStep(int at) =>
      !isOver && !pieOpen && cells[at] == 0;

  /// Your step, and the mere's answer unless the marsh is settled.
  Play step(int at) {
    if (!mayStep(at)) return this;
    final stepped = List.of(cells);
    stepped[at] = 1;
    final next = Play._(
        field, rules, stepped, moves + 1, false, swapped, this);
    return next._houseSteps();
  }

  Play _houseSteps() {
    if (isOver) return this;
    final reply = rules.bestStep(cells, 2);
    if (reply == -1) return this;
    final grown = List.of(cells);
    grown[reply] = 2;
    return Play._(
        field, rules, grown, moves, false, swapped, before ?? this);
  }

  Play get back => before ?? this;

  /// Who wins from here with you to step, both perfect.
  int get standing => rules.winner(List.of(cells), 1);

  /// The step the solve keeps the win with, or the pie judgment;
  /// null when nothing saves the marsh.
  String? get next {
    if (isOver) return null;
    if (pieOpen) {
      // Judge the pie by what each road holds.
      final taken = takePie();
      if (!taken.isOver && taken.standing == 1) return 'take';
      final waved = declinePie();
      return waved.standing == 1 ? 'decline' : null;
    }
    if (standing != 1) return null;
    return '${rules.bestStep(List.of(cells), 1)}';
  }
}
