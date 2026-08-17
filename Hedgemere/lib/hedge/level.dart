import 'rules.dart';

/// One ask: what the hedge is to peel down to, and in how many rounds.
class Level {
  const Level({
    required this.name,
    required this.middles,
    required this.rounds,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// How many posts are to be left standing.
  final int middles;

  /// How many rounds of stripping it is to take.
  final int rounds;

  /// How many hangings land it, from the sweep.
  final int ways;

  /// The cheapest hanging that lands it, from the sweep; null when none
  /// does.
  final List<int>? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the hanging lands the ask.
  bool meets(List<int> hanging) {
    if (!Rules.validHanging(hanging)) return false;
    final (middle, rounds, _) = Rules.peel(hanging);
    return middle.length == middles && rounds == this.rounds;
  }

  /// The taps the cheapest hanging takes from the opening.
  int? get fewest =>
      aim == null ? null : Rules.taps(Rules.opening, aim!);

  /// The task, told in words. The hopeless ask says nothing about
  /// rounds, since no number of them would help.
  String get task => switch (middles) {
        1 => 'peel the hedge down to a single middle post in '
            '${Rules.tellRounds(rounds)}',
        2 => 'peel the hedge down to two middle posts in '
            '${Rules.tellRounds(rounds)}',
        _ => 'peel the hedge down to three middle posts',
      };
}
