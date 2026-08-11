/// One tower job, as it ships.
class Spindle {
  const Spindle({
    required this.name,
    required this.spindles,
    required this.rounds,
    required this.fewest,
    this.wager,
    this.note,
  });

  final String name;
  final int spindles;
  final int rounds;

  /// The fewest moves home, as the walk verified it.
  final int fewest;

  /// A move count the job dares you to meet, where one does. The walk
  /// says it cannot be met; that is the point of it.
  final int? wager;

  final String? note;
}
