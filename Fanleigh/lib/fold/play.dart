import 'fold.dart';
import 'rules.dart';

/// A paddock being folded. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.fold, this.rules, this.hurdles, this.picked, this.moves,
      this.before);

  factory Play.of(Fold fold) =>
      Play._(fold, Rules(fold.posts), const [], null, 0, null);

  /// A play stood at a fencing, for the mark and the tests.
  factory Play.standing(Fold fold, List<(int, int)> hurdles) =>
      Play._(fold, Rules(fold.posts), List.of(hurdles), null,
          hurdles.length, null);

  final Fold fold;
  final Rules rules;

  /// The hurdles as they stand.
  final List<(int, int)> hurdles;

  /// The post picked towards a hurdle, or null.
  final int? picked;

  /// Layings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless fold admits it.
  static const gaveUpAt = 12;

  List<((int, int), (int, int))> get crossings =>
      Rules.crossings(hurdles);

  bool get fenced => rules.fenced(hurdles);

  List<int> get crown => fenced
      ? rules.crown(hurdles)
      : List.filled(fold.posts, 0);

  List<int> get ears => fenced ? rules.ears(hurdles) : const [];

  bool get isDone => fenced && fold.lands(rules.crown(hurdles));

  bool get gaveUp => !fold.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether two posts could take a hurdle: not neighbours on
  /// the rim.
  bool couldHurdle(int a, int b) {
    if (a == b) return false;
    final gap = (a - b).abs();
    return gap >= 2 && gap <= fold.posts - 2;
  }

  /// Picks a post; the second lays the hurdle, or lifts it if it
  /// already stands.
  Play tapAt(int post) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(fold, rules, hurdles, post, moves, before);
    }
    if (one == post) {
      return Play._(fold, rules, hurdles, null, moves, before);
    }
    if (!couldHurdle(one, post)) {
      return Play._(fold, rules, hurdles, null, moves, before);
    }
    final hurdle = one < post ? (one, post) : (post, one);
    if (hurdles.contains(hurdle)) {
      return Play._(
          fold,
          rules,
          [for (final h in hurdles) if (h != hurdle) h],
          null,
          moves + 1,
          this);
    }
    if (hurdles.length == fold.posts - 3) {
      return Play._(fold, rules, hurdles, null, moves, before);
    }
    return Play._(
        fold, rules, [...hurdles, hurdle], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The hurdle the sweep would lay or lift next towards its
  /// fencing; null when none lands the asking.
  ((int, int), bool)? get next {
    final aim = rules.fencing(fold.lands);
    if (aim == null || isDone) return null;
    for (final hurdle in hurdles) {
      if (!aim.contains(hurdle)) return (hurdle, false);
    }
    for (final hurdle in aim) {
      if (!hurdles.contains(hurdle)) return (hurdle, true);
    }
    return null;
  }
}
