import 'rules.dart';

/// One ask: bounce the light off the mirror and bring the whole path
/// within so many paces.
class Level {
  const Level({
    required this.name,
    required this.paces,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The paces the whole path is to be brought within.
  final int paces;

  /// How many of the mirror's pegs land it. The sweep's number, and the
  /// checker refuses the bake if it drifts.
  final int ways;

  /// The slides from the opening to the nearest bounce that lands it;
  /// null when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  /// Where the lamp stands. Every ask shares one board, since the whole
  /// game is what happens as the asking tightens.
  static const lampX = 2, lampY = 4;

  /// Where the eye stands.
  static const eyeX = 8, eyeY = 4;

  /// Where the bounce starts, at the far left, which lands none of the
  /// asks.
  static const opening = 0;

  /// The squared straight run to the eye folded across the mirror.
  static int get folded => Rules.folded(lampX, lampY, eyeX, eyeY);

  /// The fewest paces any path can come to, which is that straight run.
  static int get least => Rules.root(folded)!;

  bool get winnable => ways > 0;

  /// Whether a bounce lands the ask.
  bool meets(int bounce) {
    final (one, two) = Rules.legs(lampX, lampY, eyeX, eyeY, bounce);
    return Rules.within(one, two, paces);
  }

  /// The task, told in words.
  String get task =>
      'slide the bounce so the whole path comes within $paces paces';
}
