/// A morning at the kiln: a ladder, some pots, and a question.
///
/// Somewhere on the ladder is the highest rung a pot of this batch can be
/// dropped from and live. It might be none of them. The only way to ask is to
/// drop a pot, and a pot that breaks is gone.
class Ladder {
  const Ladder({
    required this.name,
    required this.rungs,
    required this.pots,
    required this.fewest,
  });

  final String name;

  /// How many rungs the ladder has.
  final int rungs;

  /// How many pots there are to break.
  final int pots;

  /// The fewest drops that are certain to settle it, whatever the batch turns
  /// out to be. Written down here as well as worked out, so a test can hold
  /// the two against each other.
  final int fewest;

  /// How many answers there are: any rung could be the highest safe one, or
  /// no rung at all is safe.
  int get answers => rungs + 1;
}

/// What is still possible part way through: the highest safe rung is somewhere
/// in [lowest]..[highest], counting 0 for no rung being safe.
class Standing {
  const Standing({required this.lowest, required this.highest});

  final int lowest;
  final int highest;

  int get answers => highest - lowest + 1;

  bool get settled => lowest == highest;

  /// The rungs still worth dropping from: anything that would split this.
  bool worthDropping(int rung) => rung > lowest && rung <= highest;
}
