/// One line on the sham: how many prisoners, how the caps fall, whether
/// the warden caps the first man against his word, and what the sweep
/// found.
class Level {
  const Level({
    required this.name,
    required this.prisoners,
    required this.dealt,
    this.warden = false,
    required this.ways,
    required this.deals,
    this.note,
  });

  final String name;
  final int prisoners;

  /// The caps as bits, bit i for prisoner i, black when set.
  final int dealt;

  /// Whether the warden sets the first man's cap against his call, so
  /// that all must be saved and the first never is.
  final bool warden;

  /// Deals on which the plan lands the ask, by the sweep.
  final int ways;

  /// Deals of caps, all told: two to the prisoners.
  final int deals;

  /// One thing worth knowing about this line, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six'};

  /// The task, told in words for the ledger.
  String get task => warden
      ? 'save all ${_words[prisoners]} of the line, the warden capping the first man after he speaks'
      : 'save all but the first of the line of ${_words[prisoners]}';
}
