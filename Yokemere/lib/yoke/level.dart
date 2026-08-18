import 'rules.dart';

/// One ask: bring the team's pull to a given figure.
class Level {
  const Level({
    required this.name,
    required this.pull,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The pull the team is to come to, exactly.
  final int pull;

  /// How many yokings land it. The sweep's number, and the checker
  /// refuses the bake if it drifts.
  final int ways;

  /// The swaps from the opening to the nearest yoking that lands it;
  /// null when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether this yoking lands the ask.
  bool meets(List<int> order) => Rules.pull(order) == pull;

  /// The task, told in words.
  String get task => 'yoke the rows so the team pulls exactly $pull';
}
