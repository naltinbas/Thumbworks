import 'ground.dart';
import 'rules.dart';

/// A chase in progress. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.ground, this.rules, this.cat, this.mouse, this.rounds,
      this.caught, this.before);

  factory Play.of(Ground ground) {
    final rules = Rules(ground.posts, ground.paths);
    final cat = ground.catStart;
    return Play._(
        ground, rules, cat, rules.mouseStart(cat), 0, false, null);
  }

  final Ground ground;
  final Rules rules;

  /// Where the cat and the mouse stand.
  final int cat;
  final int mouse;

  /// Rounds taken: one cat step and the mouse's reply.
  final int rounds;

  final bool caught;

  final Play? before;

  /// The futility line for a ground the mouse holds forever.
  static const gaveUpAt = 8;

  bool get gaveUp => !ground.winnable && rounds >= gaveUpAt;

  bool get isOver => caught || gaveUp;

  bool mayStep(int to) =>
      !isOver && rules.movesFrom(cat).contains(to);

  /// One round: the cat steps; the mouse replies unless caught.
  Play step(int to) {
    if (!mayStep(to)) return this;
    if (to == mouse) {
      return Play._(
          ground, rules, to, mouse, rounds + 1, true, this);
    }
    final fled = rules.mouseMove(to, mouse);
    return Play._(
        ground, rules, to, fled, rounds + 1, false, this);
  }

  Play get back => before ?? this;

  /// Rounds to the catch from here with best play, or null.
  int? get toCatch {
    final rounds = rules.catchIn[cat][mouse];
    return rounds == -1 ? null : rounds;
  }

  /// The cat's best step, or null.
  int? get next => isOver ? null : rules.catMove(cat, mouse);
}
