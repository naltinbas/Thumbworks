import 'level.dart';
import 'rules.dart';

/// A number being made. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.picked, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [], 0, null);

  /// A play stood at a picking, for the mark and the tests.
  factory Play.standing(Level level, List<int> picked) => Play._(level, List.of(picked), picked.length, null);

  final Level level;

  /// The stones picked, in the order picked.
  final List<int> picked;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless number admits it.
  static const gaveUpAt = 12;

  List<int> get stones => Rules.stones(level.number);

  int get sum => picked.fold(0, (a, b) => a + b);

  bool get full => picked.length >= level.count;

  bool get isDone => full && sum == level.number;

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks the stone [s] from the rack, if there is room.
  Play pick(int s) {
    if (isOver || full || !stones.contains(s)) return this;
    return Play._(level, [...picked, s], moves + 1, this);
  }

  /// Lifts the stone at [i] among those picked.
  Play lift(int i) {
    if (isOver || i < 0 || i >= picked.length) return this;
    return Play._(level, [for (var j = 0; j < picked.length; j++) if (j != i) picked[j]], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', place) for a picked stone off
  /// the sweep's first making, else ('pick', stone) for the next stone of
  /// it; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    // Match the picked stones to the aim, each stone once.
    final left = List.of(aim);
    for (var i = 0; i < picked.length; i++) {
      if (!left.remove(picked[i])) return ('lift', i);
    }
    return left.isEmpty ? null : ('pick', left.first);
  }

  /// The sweep's first making of the number, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final found = Rules.makings(level.number, level.count);
      _aims[level.name] = found.isEmpty ? null : found.first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
