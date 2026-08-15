/// One riffle on the sham: the deck, the cut, whether the packet is
/// turned, what is asked, and what the sweep found.
class Riffle {
  const Riffle({
    required this.name,
    required this.deck,
    required this.cut,
    required this.turned,
    required this.kinds,
    required this.wantMixed,
    required this.ways,
    required this.riffles,
    this.note,
  });

  final String name;
  final String deck;
  final int cut;
  final bool turned;
  final int kinds;

  /// True when every block must come out mixed; false when some
  /// block must come out unmixed.
  final bool wantMixed;

  /// Full riffles that land, by the sweep; nought for the hopeless.
  final int ways;

  /// Full riffles there are.
  final int riffles;

  /// One thing worth knowing about this riffle, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _kindWords = {2: 'pair', 3: 'triple'};

  /// The task, told in words for the ledger.
  String get task {
    final packet = turned ? 'the packet turned' : 'the packet not turned';
    final aim = wantMixed
        ? 'every ${_kindWords[kinds]} mixed'
        : 'some ${_kindWords[kinds]} unmixed';
    return 'cut ${deck.length} at $cut, $packet, and riffle so $aim';
  }
}
