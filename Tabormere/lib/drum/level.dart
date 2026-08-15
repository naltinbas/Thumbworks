import 'rules.dart';

/// One ask: so many hits in so many steps, even, or with equal gaps.
class Level {
  const Level({
    required this.name,
    required this.steps,
    required this.hits,
    this.equalGapsAsked = false,
    required this.ways,
    required this.note,
  });

  final String name;
  final int steps;
  final int hits;

  /// Whether the ask wants every gap the same, not just an even spread.
  final bool equalGapsAsked;

  /// How many patterns land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  int get patterns => Rules.choose(steps, hits);

  /// Whether the hits at [hitsAt] land the ask.
  bool meets(List<int> hitsAt) => hitsAt.length == hits && (equalGapsAsked ? Rules.equalGaps(steps, hitsAt) : Rules.isEven(steps, hitsAt));

  /// The pattern the pointer works towards, Euclid's, or null when none
  /// lands it.
  List<int>? get aim => winnable ? Rules.euclid(steps, hits) : null;

  /// The task, told in words for the ledger.
  String get task => equalGapsAsked
      ? 'set ${_word(hits)} hits in ${_word(steps)} steps with the same gap between every pair'
      : 'set ${_word(hits)} hits in ${_word(steps)} steps as evenly as they can go';

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen'][n];
}
