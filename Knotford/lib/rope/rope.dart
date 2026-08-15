/// One rope on the sham: how many knots, and what the sweep found.
class Rope {
  const Rope({
    required this.name,
    required this.knots,
    required this.ways,
    required this.markings,
    this.note,
  });

  final String name;
  final int knots;

  /// Markings that square the corner, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Ways of standing the two pegs on the rope.
  final int markings;

  /// One thing worth knowing about this rope, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {12: 'twelve', 25: 'twenty-five', 30: 'thirty', 40: 'forty', 60: 'sixty'};

  /// The task, told in words for the ledger.
  String get task => 'stand two pegs on the rope of ${_words[knots] ?? '$knots'} knots so the corner comes square';
}
