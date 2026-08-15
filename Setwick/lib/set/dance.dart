/// One set on the sham: the caller's number and what the sweep
/// found.
class Dance {
  const Dance({
    required this.name,
    required this.caller,
    required this.pairings,
    required this.ways,
    this.note,
  });

  final String name;
  final int caller;

  /// How many ways the dancers pair off at all, by the sweep.
  final int pairings;

  /// How many of them land; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this set, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get pairs => (caller - 3) ~/ 2;

  /// The task, told in words for the ledger.
  String get task =>
      'pair off the dancers 2 to ${caller - 2} of the set of $caller '
      'so every pair comes to one';
}
