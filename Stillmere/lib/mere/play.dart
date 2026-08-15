import 'lighting.dart';
import 'rules.dart';

/// A lighting being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.lighting, this.rules, this.lit, this.moves, this.before);

  factory Play.of(Lighting lighting) => Play._(lighting, Rules(), const {}, 0, null);

  /// A play stood at a lighting, for the mark and the tests.
  factory Play.standing(Lighting lighting, Set<Spot> lit) =>
      Play._(lighting, Rules(), Set.of(lit), lit.length, null);

  final Lighting lighting;
  final Rules rules;

  /// The lit spots.
  final Set<Spot> lit;

  /// Lightings and dousings, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless lighting admits it.
  static const gaveUpAt = 11;

  Set<Spot> get births => Rules.births(lit);
  Set<Spot> get deaths => Rules.deaths(lit);

  bool get still => Rules.still(lit);

  bool get isDone => lit.length == lighting.count && still;

  bool get gaveUp => !lighting.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(Spot spot) =>
      !isOver && spot.$1 >= 0 && spot.$1 < rules.side && spot.$2 >= 0 && spot.$2 < rules.side &&
      (lit.contains(spot) || lit.length < lighting.count);

  /// Taps a spot: lights it, or douses it.
  Play tap(Spot spot) {
    if (!touches(spot)) return this;
    final held = Set.of(lit);
    if (!held.remove(spot)) held.add(spot);
    return Play._(lighting, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('douse', spot) for a light off the
  /// aim, or ('light', spot) for the next of the aim; null when nothing
  /// lands.
  (String, Spot)? get next {
    if (isOver || !lighting.winnable) return null;
    final aim = aimFor(lighting);
    if (aim == null) return null;
    for (final spot in lit) {
      if (!aim.contains(spot)) return ('douse', spot);
    }
    for (final spot in aim) {
      if (!lit.contains(spot)) return ('light', spot);
    }
    return null;
  }

  /// The sweep's first still lighting, kept once found.
  static Set<Spot>? aimFor(Lighting lighting) {
    if (!_aims.containsKey(lighting.count)) {
      _aims[lighting.count] = Rules().landing(lighting.count);
    }
    return _aims[lighting.count];
  }

  static final _aims = <int, Set<Spot>?>{};
}
