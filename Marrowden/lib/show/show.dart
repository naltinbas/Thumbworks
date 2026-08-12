/// One bench at the show: how many marrows, and what is claimed.
class Show {
  const Show({
    required this.name,
    required this.marrows,
    required this.skip,
    required this.wins,
    required this.of,
    this.swept,
    this.sure = false,
    this.note,
  });

  final String name;

  /// Marrows on the bench each sitting.
  final int marrows;

  /// How many the rule waves by before it will take.
  final int skip;

  /// Sittings the rule wins, of all [of] there are.
  final int wins;
  final int of;

  /// Every rank-based rule swept, when the bench is short enough to
  /// hold them all; the rule's count is then the ceiling itself.
  final int? swept;

  /// The hopeless asking: land the best every sitting. No rule does.
  final bool sure;

  /// One thing worth knowing about this bench, said by the why.
  final String? note;

  /// Sittings to win before the bench is called done.
  static const asked = 5;

  bool get winnable => !sure;
}
