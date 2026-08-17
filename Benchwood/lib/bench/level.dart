import 'rules.dart';

/// One ask: a job card, a bench of so many slots, and the walks
/// allowed.
class Level {
  const Level({
    required this.name,
    required this.card,
    required this.slots,
    required this.walks,
    required this.ways,
    required this.runs,
    required this.note,
  });

  final String name;

  /// The tools the card calls for, in order, named by when they are
  /// first called.
  final List<int> card;

  /// How many tools the bench holds.
  final int slots;

  /// The walks the ask allows.
  final int walks;

  /// How many ways of playing the card keep to that, counted over every
  /// way the card can be played out.
  final int ways;

  /// How many ways of playing the card there are at all.
  final int runs;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// The fewest walks the card can be done in.
  int get fewest => Rules.fewestWalks(card, slots);

  /// Whether a finished run of [taken] walks lands the ask.
  bool meets(int taken) => winnable && taken <= walks;

  /// The task, told in words for the ledger.
  String get task => 'work the card of ${card.length} calls on a bench of '
      '$slots slots in $walks walk${walks == 1 ? '' : 's'}';
}
