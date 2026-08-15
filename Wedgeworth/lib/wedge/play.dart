import 'level.dart';
import 'rules.dart';

/// A corner being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.sides, this.faces, this.moves, this.before);

  /// The sham opens on four squares, flat: the square tiling.
  factory Play.of(Level level) => Play._(level, 4, 4, 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, int sides, int faces) => Play._(level, sides, faces, 0, null);

  final Level level;

  /// The sides of each face.
  final int sides;

  /// The faces meeting at the corner.
  final int faces;

  /// Settings made, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 12;

  (int, int) get angle => Rules.angle(sides);
  (int, int) get sum => Rules.sum(sides, faces);
  (int, int) get gap => Rules.gap(sides, faces);
  bool get closes => Rules.closes(sides, faces);
  bool get flat => Rules.flat(sides, faces);
  bool get overlaps => Rules.overlaps(sides, faces);
  (int, int, int)? get euler => Rules.euler(sides, faces);
  String? get solid => Rules.solid(sides, faces);
  String? get tiling => Rules.tiling(sides, faces);

  bool get isDone => level.meets(sides, faces);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets the sides of the faces.
  Play setSides(int p) {
    if (isOver || !Rules.sides.contains(p) || p == sides) return this;
    return Play._(level, p, faces, moves + 1, this);
  }

  /// Sets how many faces meet.
  Play setFaces(int q) {
    if (isOver || !Rules.faces.contains(q) || q == faces) return this;
    return Play._(level, sides, q, moves + 1, this);
  }

  /// Sets dial 0, the sides, or dial 1, the faces, to [value].
  Play set(int dial, int value) => dial == 0 ? setSides(value) : setFaces(value);

  Play get back => before ?? this;

  /// What the show-me points at: (dial, value), the first dial off the
  /// sweep's first setting; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    if (sides != aim.$1) return (0, aim.$1);
    if (faces != aim.$2) return (1, aim.$2);
    return null;
  }

  /// The sweep's first setting for the ask, kept once found.
  static (int, int)? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, (int, int)?>{};
}
