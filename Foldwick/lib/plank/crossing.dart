/// One crossing on the sham: the flock, the rule, and what the walk
/// found.
class Crossing {
  const Crossing({
    required this.name,
    required this.sheep,
    required this.goats,
    required this.jumps,
    required this.moves,
    required this.ways,
    this.note,
  });

  final String name;
  final int sheep;
  final int goats;

  /// Whether jumping is allowed.
  final bool jumps;

  /// The moves every crossing takes; nought for the hopeless.
  final int moves;

  /// How many crossings there are; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this crossing, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {1: 'one', 2: 'two', 3: 'three'};

  /// The task, told in words for the ledger.
  String get task =>
      'pass ${_words[sheep]} sheep and ${_words[goats]} goat${goats == 1 ? '' : 's'} '
      'to the other ends${jumps ? '' : ', steps only'}';
}
