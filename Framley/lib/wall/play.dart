import 'level.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { tray, cell, lift }

/// A wall being hung. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.hung, this.held, this.moves, this.before, this.refused);

  factory Play.of(Level level) => Play._(level, Map.of(level.fixed), null, 0, null, false);

  /// A play stood at a hanging, for the mark and the tests.
  factory Play.standing(Level level, Map<int, (int, int)> hung) => Play._(level, Map.of(hung), null, 0, null, false);

  final Level level;

  /// Each hung frame's top left corner, by size.
  final Map<int, (int, int)> hung;

  /// The frame held from the tray, or null.
  final int? held;

  /// Hangings made, counted; lifts are free.
  final int moves;

  final Play? before;

  /// Whether the last tap tried to hang a frame where it does not fit.
  final bool refused;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  List<int> get sizes => level.sizes;

  /// The frames still in the tray, largest first.
  List<int> get tray => sizes.where((s) => !hung.containsKey(s)).toList()..sort((a, b) => b - a);

  int get bareCells => level.area - hung.keys.fold(0, (sum, s) => sum + s * s);

  bool get isFull => hung.length == sizes.length;

  bool get isDone => level.meets(hung);

  /// The hopeless ask admits it once the wall is full or the hangings run out.
  bool get gaveUp => !level.winnable && !isDone && (isFull || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Whether a frame of [s] would hang at (x, y): inside the wall and
  /// over bare cells only.
  bool fits(int s, int x, int y) {
    if (x < 0 || y < 0 || x + s > level.width || y + s > level.height) return false;
    for (final e in hung.entries) {
      final (ox, oy) = e.value;
      if (ox < x + s && x < ox + e.key && oy < y + s && y < oy + e.key) return false;
    }
    return true;
  }

  /// The frame hung over cell (x, y), or null.
  int? frameAt(int x, int y) {
    for (final e in hung.entries) {
      final (ox, oy) = e.value;
      if (x >= ox && x < ox + e.key && y >= oy && y < oy + e.key) return e.key;
    }
    return null;
  }

  /// Taps a tray frame: held, or let go if held already.
  Play hold(int s) {
    if (isOver || hung.containsKey(s) || !sizes.contains(s)) return this;
    return Play._(level, hung, held == s ? null : s, moves, this, false);
  }

  /// Taps wall cell (x, y): hangs the held frame with its top left
  /// corner there, or lifts the frame over the cell back to the tray.
  Play tap(int x, int y) {
    if (isOver) return this;
    final h = held;
    if (h != null) {
      if (!fits(h, x, y)) return Play._(level, hung, held, moves, this, true);
      final next = Map.of(hung)..[h] = (x, y);
      return Play._(level, next, null, moves + 1, this, false);
    }
    final over = frameAt(x, y);
    if (over == null || level.fixed.containsKey(over)) return this;
    final next = Map.of(hung)..remove(over);
    return Play._(level, next, null, moves, this, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the next thing to do toward the
  /// search's first hanging; null when nothing lands.
  (Aim, int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final order = aim.keys.toList()..sort((a, b) => aim[a]!.$2 != aim[b]!.$2 ? aim[a]!.$2 - aim[b]!.$2 : aim[a]!.$1 - aim[b]!.$1);
    for (final s in order) {
      final want = aim[s]!;
      final at = hung[s];
      if (at == want) continue;
      if (at != null) return (Aim.lift, at.$1, at.$2);
      // Whatever sits on its place must go first.
      for (var j = want.$2; j < want.$2 + s; j++) {
        for (var i = want.$1; i < want.$1 + s; i++) {
          final blocker = frameAt(i, j);
          if (blocker != null) {
            final (bx, by) = hung[blocker]!;
            return (Aim.lift, bx, by);
          }
        }
      }
      if (held == s) return (Aim.cell, want.$1, want.$2);
      return (Aim.tray, s, 0);
    }
    return null;
  }

  /// The search's first hanging for the ask, kept once found.
  static Map<int, (int, int)>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final found = Rules.hangings(level.width, level.height, level.sizes, fixed: level.fixed, smallestOnRim: level.smallestOnRim, atMost: 1);
      _aims[level.name] = found.isEmpty ? null : found.first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, Map<int, (int, int)>?>{};
}
