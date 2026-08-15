import 'level.dart';
import 'rules.dart';

/// A parish being drawn. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.wards, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, List<int?>.filled(Rules.cells, null), 0, null);

  /// A play stood at a drawing, for the mark and the tests.
  factory Play.standing(Level level, List<int?> wards) => Play._(level, List.of(wards), 0, null);

  final Level level;

  /// Each household's ward, or null while bare.
  final List<int?> wards;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it: a whole drawing can
  /// take a hundred and twenty-five taps.
  static const gaveUpAt = 150;

  List<bool> get blue => level.blue;

  bool get sound => Rules.sound(wards);

  int get assigned => wards.where((w) => w != null).length;

  List<int> get tally => Rules.tally(wards, blue);

  /// The wards the Blues win as things stand, counting only sound wards
  /// of five.
  int get blueWins {
    var wins = 0;
    for (var w = 0; w < Rules.wards; w++) {
      final members = [for (var c = 0; c < Rules.cells; c++) if (wards[c] == w) c];
      if (members.length != Rules.wardSize) continue;
      if (members.where((c) => blue[c]).length >= 3) wins++;
    }
    return wins;
  }

  /// The wards that are five households in one piece.
  List<bool> get wardsSound => List.generate(Rules.wards, (w) {
        final members = [for (var c = 0; c < Rules.cells; c++) if (wards[c] == w) c];
        if (members.length != Rules.wardSize) return false;
        final seen = {members.first};
        final stack = [members.first];
        while (stack.isNotEmpty) {
          final c = stack.removeLast();
          for (final n in Rules.neighbours(c)) {
            if (wards[n] == w && seen.add(n)) stack.add(n);
          }
        }
        return seen.length == Rules.wardSize;
      });

  bool get isDone => level.meets(wards);

  /// The hopeless ask admits it once a sound drawing is down that does
  /// not land, or the taps run out.
  bool get gaveUp => !level.winnable && !isDone && ((sound && !isDone) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Taps household [c]: its ward goes round, bare, one to five, bare.
  Play tap(int c) {
    if (isOver || c < 0 || c >= Rules.cells) return this;
    final next = List.of(wards);
    final now = wards[c];
    next[c] = now == null ? 0 : now == Rules.wards - 1 ? null : now + 1;
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the first household whose ward is not
  /// the aim's, and how many taps set it; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var c = 0; c < Rules.cells; c++) {
      if (wards[c] != aim[c]) {
        final now = wards[c];
        final nowStep = now == null ? 0 : now + 1;
        final wantStep = aim[c] + 1;
        return (c, (wantStep - nowStep) % (Rules.wards + 1));
      }
    }
    return null;
  }

  /// The first drawing that lands the ask, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      List<int>? found;
      for (final d in Rules.drawings) {
        if (level.meets(d)) {
          found = d;
          break;
        }
      }
      _aims[level.name] = found;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
