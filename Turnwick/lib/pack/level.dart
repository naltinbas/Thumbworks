import 'rules.dart';

/// One pattern on the sham: how many cards, which places are to lie
/// face up, and what the walk found.
class Level {
  const Level({
    required this.name,
    required this.cards,
    required this.pattern,
    required this.moves,
    required this.ways,
    required this.sequences,
    this.note,
  });

  final String name;

  /// Cards in the pack.
  final int cards;

  /// The faces asked, top down: true for up.
  final List<bool> pattern;

  /// The fewest moves that reach it, by the walk, and the moves swept.
  final int moves;

  /// Sequences of so many moves that end on the pattern, by the sweep;
  /// nought for the hopeless.
  final int ways;

  /// Sequences of so many moves, all of them: two to the moves.
  final int sequences;

  /// One thing worth knowing about this pattern, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(cards);

  static const _words = {1: 'one', 2: 'two', 4: 'four', 6: 'six', 7: 'seven'};

  /// The places asked up, said: 'the first and the last'.
  String get placesSaid {
    final ups = [for (var i = 0; i < pattern.length; i++) if (pattern[i]) i + 1];
    if (ups.length == pattern.length) return 'every card';
    const ordinals = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth'];
    final names = ups.map((u) => 'the ${ordinals[u - 1]}').toList();
    if (names.length == 1) return '${names.single} card alone';
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  /// The task, told in words for the ledger.
  String get task {
    final ups = pattern.where((p) => p).length;
    return 'cut and turn the ${_words[cards] ?? '$cards'} cards till $placesSaid ${ups == 1 || ups == cards ? 'lies' : 'lie'} face up';
  }
}
