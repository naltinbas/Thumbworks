import 'level.dart';
import 'rules.dart';

/// A hexagon being tiled. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.hexagon, this.laid, this.held, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.hexagon, const [], null, 0, null);

  /// A play stood at a tiling, for the mark and the tests.
  factory Play.standing(Level level, List<Lozenge> laid) =>
      Play._(level, level.hexagon, List.of(laid), null, laid.length, null);

  final Level level;
  final Hexagon hexagon;

  /// The lozenges laid, in order.
  final List<Lozenge> laid;

  /// A triangle picked and not yet paired, or null.
  final Tri? held;

  /// Lozenges laid and lifted, counted together.
  final int moves;

  final Play? before;

  bool covered(Tri t) => laid.any((l) => l.$1 == t || l.$2 == t);

  Lozenge? lozengeAt(Tri t) {
    for (final l in laid) {
      if (l.$1 == t || l.$2 == t) return l;
    }
    return null;
  }

  int get bare => hexagon.triangles.length - 2 * laid.length;

  bool get isDone => bare == 0;

  /// Whether any lozenge can still be laid.
  bool get canLay {
    for (final up in hexagon.ups) {
      if (covered(up)) continue;
      for (final d in Hexagon.mates(up)) {
        if (hexagon.holds(d) && !covered(d)) return true;
      }
    }
    return false;
  }

  bool get gaveUp => !level.winnable && !isDone && !canLay;

  bool get isOver => isDone || gaveUp;

  bool touches(Tri t) => !isOver && hexagon.holds(t);

  /// Taps a triangle: lifts the lozenge on it, or holds it, or lays a
  /// lozenge between it and the held one.
  Play tap(Tri t) {
    if (!touches(t)) return this;
    final on = lozengeAt(t);
    if (on != null) {
      return Play._(level, hexagon, [for (final l in laid) if (l != on) l], null, moves + 1, this);
    }
    final h = held;
    if (h == null || h == t) {
      return Play._(level, hexagon, laid, h == t ? null : t, moves, before, );
    }
    final l = hexagon.lozenge(h, t);
    if (l == null) {
      return Play._(level, hexagon, laid, t, moves, before);
    }
    return Play._(level, hexagon, [...laid, l], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', lozenge) for one off the aim,
  /// or ('lay', lozenge) for the next of the aim; null when nothing
  /// lands.
  (String, Lozenge)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final l in laid) {
      if (!aim.contains(l)) return ('lift', l);
    }
    for (final l in aim) {
      if (!laid.contains(l)) return ('lay', l);
    }
    return null;
  }

  /// The sweep's first tiling, kept once found.
  static List<Lozenge>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = level.hexagon.first();
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<Lozenge>?>{};
}
