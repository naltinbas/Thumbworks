/// One tray on the sham: how many cups, how many turn over at a time,
/// which start down, how many turns are allowed, and what the sweep
/// found.
class Level {
  const Level({
    required this.name,
    required this.cups,
    required this.each,
    required this.down,
    required this.turns,
    required this.ways,
    required this.sequences,
    this.note,
  });

  final String name;
  final int cups;

  /// Cups turned over in one turn, exactly.
  final int each;

  /// The cups down at the start, as bits.
  final int down;

  /// Turns allowed, exactly: the fewest that right the tray.
  final int turns;

  /// Sequences of that many turns that right the tray, by the sweep.
  final int ways;

  /// Sequences of that many turns, all told.
  final int sequences;

  /// One thing worth knowing about this tray, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six'};

  int get downCount {
    var n = 0;
    for (var t = down; t > 0; t >>= 1) {
      n += t & 1;
    }
    return n;
  }

  /// The task, told in words for the ledger.
  String get task =>
      'right ${_words[cups]} cups, ${_words[downCount]} down, turning ${_words[each]} at a time, in ${_words[turns]} turn${turns == 1 ? '' : 's'}';
}
