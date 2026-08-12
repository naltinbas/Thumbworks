import 'down.dart';
import 'rules.dart';

/// A down being tethered. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.down, this.rules, this.ropes, this.picked, this.moves,
      this.before);

  factory Play.of(Down down) =>
      Play._(down, Rules(down.posts), const [], null, 0, null);

  /// A play stood at a tethering, for the mark and the tests.
  factory Play.standing(Down down, List<(int, int)> ropes) => Play._(
      down, Rules(down.posts), List.of(ropes), null, ropes.length, null);

  final Down down;
  final Rules rules;

  /// The ropes as they stand.
  final List<(int, int)> ropes;

  /// The post picked towards a rope, or null.
  final int? picked;

  /// Tyings and untyings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless down admits it.
  static const gaveUpAt = 12;

  List<(int, int, int)> get knotted => rules.triangles(ropes);

  bool get isDone =>
      ropes.length == down.asked && knotted.isEmpty;

  bool get gaveUp => !down.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a post; the second post ties the rope, or unties it if
  /// it already stands.
  Play tapAt(int post) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(down, rules, ropes, post, moves, before);
    }
    if (one == post) {
      return Play._(down, rules, ropes, null, moves, before);
    }
    final rope = one < post ? (one, post) : (post, one);
    if (ropes.contains(rope)) {
      return Play._(
          down,
          rules,
          [for (final r in ropes) if (r != rope) r],
          null,
          moves + 1,
          this);
    }
    if (ropes.length == down.asked) {
      // A full down takes no more rope until one comes off.
      return Play._(down, rules, ropes, null, moves, before);
    }
    return Play._(
        down, rules, [...ropes, rope], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The rope the sweep would tie or untie next towards its
  /// tethering; null when none is in reach.
  ((int, int), bool)? get next {
    final aim = rules.tethering(down.asked);
    if (aim == null || isDone) return null;
    for (final rope in ropes) {
      if (!aim.contains(rope)) return (rope, false);
    }
    for (final rope in aim) {
      if (!ropes.contains(rope)) return (rope, true);
    }
    return null;
  }
}
