import 'level.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { tray, turn, flip, cell, lift }

/// A tray being filled. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.laid, this.held, this.facing, this.moves, this.before, this.refused);

  factory Play.of(Level level) => Play._(level, const [], null, 0, 0, null, false);

  /// A play stood at a filling, for the mark and the tests.
  factory Play.standing(Level level, List<(int, int, int, int)> laid) => Play._(level, List.of(laid), null, 0, 0, null, false);

  final Level level;

  /// The fours laid: (kind, orientation, x, y), (x, y) the top left.
  final List<(int, int, int, int)> laid;

  /// The kind held from the tray, or null.
  final int? held;

  /// The held four's orientation.
  final int facing;

  /// Layings made, counted; lifts are free.
  final int moves;

  final Play? before;

  /// Whether the last tap tried to lay a four where it does not fit.
  final bool refused;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  int get width => level.width;
  int get height => level.height;

  /// How many of kind [k] are still in the tray.
  int left(int k) => level.counts[k] - laid.where((p) => p.$1 == k).length;

  int get bareCells => width * height - laid.length * 4;

  bool get isFull => laid.length == level.pieces;

  bool get isDone => level.meets(laid);

  /// The grid of the fours laid, true where covered.
  List<List<bool>> get grid {
    final g = List.generate(height, (_) => List.filled(width, false));
    for (final (k, o, x0, y0) in laid) {
      for (final c in Rules.orientations(k)[o]) {
        g[y0 + c.$2][x0 + c.$1] = true;
      }
    }
    return g;
  }

  /// Whether some four left in the tray fits nowhere, any way up.
  bool get stuck {
    final g = grid;
    for (var k = 0; k < Rules.kinds.length; k++) {
      if (left(k) == 0) continue;
      var anywhere = false;
      for (final shape in Rules.orientations(k)) {
        for (var y = 0; y < height && !anywhere; y++) {
          for (var x = 0; x < width && !anywhere; x++) {
            if (Rules.fits(g, width, height, shape, x, y)) anywhere = true;
          }
        }
      }
      if (!anywhere) return true;
    }
    return false;
  }

  /// The hopeless ask admits it when a four has nowhere to go, or the
  /// layings run out.
  bool get gaveUp => !level.winnable && !isDone && (stuck || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Whether the held four, as facing, would lie with its top left at (x, y).
  bool fitsHeld(int x, int y) => held != null && Rules.fits(grid, width, height, Rules.orientations(held!)[facing], x, y);

  /// The index in [laid] of the four over cell (x, y), or null.
  int? fourAt(int x, int y) {
    for (var i = 0; i < laid.length; i++) {
      final (k, o, x0, y0) = laid[i];
      for (final c in Rules.orientations(k)[o]) {
        if (x0 + c.$1 == x && y0 + c.$2 == y) return i;
      }
    }
    return null;
  }

  /// Taps a tray kind: held, facing its first way, or let go if held already.
  Play hold(int k) {
    if (isOver || k < 0 || k >= Rules.kinds.length || left(k) == 0) return this;
    return Play._(level, laid, held == k ? null : k, 0, moves, this, false);
  }

  /// Turns the held four a quarter turn.
  Play turn() {
    if (isOver || held == null) return this;
    return Play._(level, laid, held, Rules.turned(held!, facing), moves, this, false);
  }

  /// Flips the held four left to right.
  Play flip() {
    if (isOver || held == null) return this;
    return Play._(level, laid, held, Rules.flipped(held!, facing), moves, this, false);
  }

  /// Taps tray cell (x, y): lays the held four with its top left there,
  /// or lifts the four over the cell back to the bag.
  Play tap(int x, int y) {
    if (isOver) return this;
    final h = held;
    if (h != null) {
      if (!fitsHeld(x, y)) return Play._(level, laid, held, facing, moves, this, true);
      final next = List.of(laid)..add((h, facing, x, y));
      return Play._(level, next, null, 0, moves + 1, this, false);
    }
    final over = fourAt(x, y);
    if (over == null) return this;
    final next = List.of(laid)..removeAt(over);
    return Play._(level, next, null, 0, moves, this, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the next thing to do toward the
  /// search's first filling; null when nothing lands.
  (Aim, int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final (k, o, x0, y0) in aim) {
      if (laid.contains((k, o, x0, y0))) continue;
      // Whatever lies on its cells goes first.
      for (final c in Rules.orientations(k)[o]) {
        final blocker = fourAt(x0 + c.$1, y0 + c.$2);
        if (blocker != null) {
          final (_, _, bx, by) = laid[blocker];
          final firstCell = Rules.orientations(laid[blocker].$1)[laid[blocker].$2].first;
          return (Aim.lift, bx + firstCell.$1, by + firstCell.$2);
        }
      }
      if (held != k) return (Aim.tray, k, 0);
      final move = Rules.firstMove(k, facing, o);
      if (move == 'turn') return (Aim.turn, 0, 0);
      if (move == 'flip') return (Aim.flip, 0, 0);
      return (Aim.cell, x0, y0);
    }
    return null;
  }

  /// The search's first filling for the ask, kept once found.
  static List<(int, int, int, int)>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, first) = Rules.fillings(level.width, level.height, level.counts, atMost: 1);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<(int, int, int, int)>?>{};
}
