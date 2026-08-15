import 'level.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { tray, peg, lift }

/// A train being geared. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.placed, this.held, this.moves, this.before, this.refused);

  factory Play.of(Level level) => Play._(level, const [], null, 0, null, false);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Level level, List<(int, int, int)> placed) => Play._(level, List.of(placed), null, 0, null, false);

  final Level level;

  /// The tray gears placed: (x, y, radius).
  final List<(int, int, int)> placed;

  /// The tray slot held, an index into the tray, or null.
  final int? held;

  /// Placings made, counted; lifts are free.
  final int moves;

  final Play? before;

  /// Whether the last tap tried to place a gear where it overlaps.
  final bool refused;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 30;

  /// All the gears, the fixed first.
  List<(int, int, int)> get gears => [...level.fixed, ...placed];

  /// Which tray slots are placed: slot i placed iff placed has a gear of
  /// that radius not claimed by an earlier slot.
  List<bool> get slotPlaced {
    final counts = <int, int>{};
    for (final g in placed) {
      counts[g.$3] = (counts[g.$3] ?? 0) + 1;
    }
    final out = <bool>[];
    final used = <int, int>{};
    for (final r in level.tray) {
      final have = counts[r] ?? 0, taken = used[r] ?? 0;
      out.add(taken < have);
      used[r] = taken + 1;
    }
    return out;
  }

  int? get heldRadius => held == null ? null : level.tray[held!];

  (List<int>, bool) get turning => Rules.turning(gears, 0);
  List<int> get ways => turning.$1;
  bool get jam => turning.$2;

  bool get isDone => level.meets(gears);

  /// The hopeless ask admits it when a ring is made and jams, or the
  /// placings run out.
  bool get gaveUp => !level.winnable && !isDone && ((placed.length == level.tray.length && jam && Rules.inRing(gears, 0)) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The gear on peg (x, y), an index into [gears], or null.
  int? gearAt(int x, int y) {
    final all = gears;
    for (var i = 0; i < all.length; i++) {
      if (all[i].$1 == x && all[i].$2 == y) return i;
    }
    return null;
  }

  /// Whether a gear of [r] would sit at (x, y) apart from every other.
  bool fits(int r, int x, int y) {
    if (x < 0 || y < 0 || x >= level.width || y >= level.height) return false;
    final gear = (x, y, r);
    return !gears.any((g) => g.$1 == x && g.$2 == y || Rules.overlap(g, gear));
  }

  /// Taps tray slot [i]: held, or let go if held already.
  Play hold(int i) {
    if (isOver || i < 0 || i >= level.tray.length || slotPlaced[i]) return this;
    return Play._(level, placed, held == i ? null : i, moves, this, false);
  }

  /// Taps peg (x, y): places the held gear there, or lifts the tray gear
  /// on it.
  Play tap(int x, int y) {
    if (isOver) return this;
    final r = heldRadius;
    if (r != null) {
      if (!fits(r, x, y)) return Play._(level, placed, held, moves, this, true);
      return Play._(level, [...placed, (x, y, r)], null, moves + 1, this, false);
    }
    final i = gearAt(x, y);
    if (i == null || i < level.fixed.length) return this;
    final next = List.of(placed)..removeAt(i - level.fixed.length);
    return Play._(level, next, null, moves, this, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the next thing to do toward the sweep's
  /// first landing placing; null when nothing lands.
  (Aim, int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final want = aim.sublist(level.fixed.length);
    // A placed gear not in the aim goes first.
    for (final g in placed) {
      if (!want.contains(g)) return (Aim.lift, g.$1, g.$2);
    }
    for (final g in want) {
      if (placed.contains(g)) continue;
      // Hold a tray slot of that radius, or place the held one.
      if (heldRadius == g.$3) return (Aim.peg, g.$1, g.$2);
      for (var i = 0; i < level.tray.length; i++) {
        if (level.tray[i] == g.$3 && !slotPlaced[i]) return (Aim.tray, i, 0);
      }
    }
    return null;
  }

  /// The sweep's first landing placing for the ask, kept once found.
  static List<(int, int, int)>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, _, first) = Rules.sweep(level.width, level.height, level.fixed, level.tray, level.meets);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<(int, int, int)>?>{};
}
