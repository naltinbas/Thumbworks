import 'lawn.dart';
import 'rules.dart';

/// A lawn being shaken. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.fete, this.rules, this.shakes, this.picked, this.moves,
      this.before);

  factory Play.of(Lawn fete) =>
      Play._(fete, Rules(fete.guests), const [], null, 0, null);

  /// A play stood at a shaking, for the mark and the tests.
  factory Play.standing(Lawn fete, List<(int, int)> shakes) =>
      Play._(fete, Rules(fete.guests), List.of(shakes), null,
          shakes.length, null);

  final Lawn fete;
  final Rules rules;

  /// The handshakes as they stand.
  final List<(int, int)> shakes;

  /// The guest picked towards a shake, or null.
  final int? picked;

  /// Shakes and unshakes taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless lawn admits it.
  static const gaveUpAt = 12;

  List<int> get oddHanded => rules.oddHanded(shakes);

  List<int> get hands => rules.hands(shakes);

  bool get isDone =>
      shakes.isNotEmpty && oddHanded.length == fete.asked;

  bool get gaveUp => !fete.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a guest; the second shakes, or unshakes a shake that
  /// already stands.
  Play tapAt(int guest) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(fete, rules, shakes, guest, moves, before);
    }
    if (one == guest) {
      return Play._(fete, rules, shakes, null, moves, before);
    }
    final shake = one < guest ? (one, guest) : (guest, one);
    if (shakes.contains(shake)) {
      return Play._(
          fete,
          rules,
          [for (final s in shakes) if (s != shake) s],
          null,
          moves + 1,
          this);
    }
    return Play._(
        fete, rules, [...shakes, shake], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The shake the sweep would make or unmake next towards its
  /// lawn; null when none lands the asking.
  ((int, int), bool)? get next {
    final aim = rules.busyLawn(fete.asked);
    if (aim == null || isDone) return null;
    for (final shake in shakes) {
      if (!aim.contains(shake)) return (shake, false);
    }
    for (final shake in aim) {
      if (!shakes.contains(shake)) return (shake, true);
    }
    return null;
  }
}
