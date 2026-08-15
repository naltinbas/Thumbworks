import 'level.dart';
import 'rules.dart';

/// A pack being cut and turned. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.level, this.pack, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules.start, 0, null);

  /// A play stood at a pack, for the mark and the tests.
  factory Play.standing(Level level, List<Card> pack, int moves) => Play._(level, List.of(pack), moves, null);

  final Level level;
  final List<Card> pack;

  /// Moves made.
  final int moves;

  final Play? before;

  /// The line past which the hopeless pattern admits it.
  static const gaveUpAt = 12;

  List<bool> get faces => Rules.faces(pack);

  int get upAtEven => Rules.upAtEven(faces);

  int get upAtOdd => Rules.upAtOdd(faces);

  bool get isDone => Rules.faceKey(faces) == Rules.faceKey(level.pattern);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Cuts the pack.
  Play get cut => isOver ? this : Play._(level, Rules.cut(pack), moves + 1, this);

  /// Turns the top two.
  Play get turn => isOver ? this : Play._(level, Rules.turn(pack), moves + 1, this);

  Play get back => before ?? this;

  /// What the show-me points at: true for a turn, false for a cut, the
  /// first move of a shortest road; null when nothing lands.
  bool? get next {
    if (isOver || !level.winnable) return null;
    final r = Rules.road(pack, level.pattern);
    if (r == null || r.isEmpty) return null;
    return r.first;
  }
}
