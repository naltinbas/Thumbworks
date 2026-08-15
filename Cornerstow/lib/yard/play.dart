import 'level.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { tray, turn, cell, lift }

/// A yard being paved. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.laid, this.held, this.upright, this.moves, this.before, this.refused);

  factory Play.of(Level level) => Play._(level, const [], null, false, 0, null, false);

  /// A play stood at a paving, for the mark and the tests.
  factory Play.standing(Level level, List<(int, int, int, int, int)> laid) => Play._(level, List.of(laid), null, false, 0, null, false);

  final Level level;

  /// The flags laid: (kind, width, height, x, y).
  final List<(int, int, int, int, int)> laid;

  /// The kind held from the tray, or null.
  final int? held;

  /// Whether a held half stands upright, its long side down the yard.
  final bool upright;

  /// Layings made, counted; lifts are free.
  final int moves;

  final Play? before;

  /// Whether the last tap tried to lay a flag where it does not fit.
  final bool refused;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  List<(int, int, int, int)> get kinds => level.flags;

  int get side => level.side;

  /// How many of kind [i] are still in the tray.
  int left(int i) => kinds[i].$4 - laid.where((p) => p.$1 == i).length;

  /// The held flag's width and height as it would lie, or null.
  (int, int)? get heldShape {
    final h = held;
    if (h == null) return null;
    final (w, ht, _, _) = kinds[h];
    if (w == ht) return (w, ht);
    return upright ? (ht, w) : (w, ht);
  }

  int get bareCells => side * side - laid.fold(0, (sum, p) => sum + p.$2 * p.$3);

  bool get isFull => laid.length == level.flagCount;

  bool get isDone => level.meets(laid);

  /// Whether some flag left in the tray fits nowhere, either way up.
  bool get stuck {
    for (var i = 0; i < kinds.length; i++) {
      if (left(i) == 0) continue;
      final (w, h, _, _) = kinds[i];
      var anywhere = false;
      for (final (pw, ph) in w == h ? [(w, h)] : [(w, h), (h, w)]) {
        for (var y = 0; y <= side - ph && !anywhere; y++) {
          for (var x = 0; x <= side - pw && !anywhere; x++) {
            if (fits(pw, ph, x, y)) anywhere = true;
          }
        }
      }
      if (!anywhere) return true;
    }
    return false;
  }

  /// The hopeless ask admits it when a flag has nowhere to go, or the
  /// layings run out.
  bool get gaveUp => !level.winnable && !isDone && (stuck || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Whether a flag [w] by [h] would lie at (x, y), inside and over bare
  /// cells only.
  bool fits(int w, int h, int x, int y) {
    if (x < 0 || y < 0 || x + w > side || y + h > side) return false;
    for (final (_, pw, ph, px, py) in laid) {
      if (px < x + w && x < px + pw && py < y + h && y < py + ph) return false;
    }
    return true;
  }

  /// The index in [laid] of the flag over cell (x, y), or null.
  int? flagAt(int x, int y) {
    for (var i = 0; i < laid.length; i++) {
      final (_, w, h, px, py) = laid[i];
      if (x >= px && x < px + w && y >= py && y < py + h) return i;
    }
    return null;
  }

  /// Taps a tray kind: held, or let go if held already.
  Play hold(int kind) {
    if (isOver || kind < 0 || kind >= kinds.length || left(kind) == 0) return this;
    return Play._(level, laid, held == kind ? null : kind, upright, moves, this, false);
  }

  /// Turns the held half the other way up.
  Play turn() {
    if (isOver) return this;
    return Play._(level, laid, held, !upright, moves, this, false);
  }

  /// Taps yard cell (x, y): lays the held flag with its top left corner
  /// there, or lifts the flag over the cell back to the tray.
  Play tap(int x, int y) {
    if (isOver) return this;
    final shape = heldShape;
    if (shape != null) {
      final (w, h) = shape;
      if (!fits(w, h, x, y)) return Play._(level, laid, held, upright, moves, this, true);
      final next = List.of(laid)..add((held!, w, h, x, y));
      return Play._(level, next, null, upright, moves + 1, this, false);
    }
    final over = flagAt(x, y);
    if (over == null) return this;
    final next = List.of(laid)..removeAt(over);
    return Play._(level, next, null, upright, moves, this, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the next thing to do toward the
  /// search's first paving; null when nothing lands.
  (Aim, int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final (kind, w, h, x, y) in aim) {
      final there = laid.any((p) => p == (kind, w, h, x, y));
      if (there) continue;
      // Whatever lies on its place goes first.
      for (var j = y; j < y + h; j++) {
        for (var i = x; i < x + w; i++) {
          final blocker = flagAt(i, j);
          if (blocker != null) {
            final (_, _, _, bx, by) = laid[blocker];
            return (Aim.lift, bx, by);
          }
        }
      }
      if (held != kind) return (Aim.tray, kind, 0);
      final shape = heldShape!;
      if (shape != (w, h)) return (Aim.turn, 0, 0);
      return (Aim.cell, x, y);
    }
    return null;
  }

  /// The search's first paving for the ask, kept once found.
  static List<(int, int, int, int, int)>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, first) = Rules.pavings(level.side, level.flags, atMost: 1);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<(int, int, int, int, int)>?>{};
}
