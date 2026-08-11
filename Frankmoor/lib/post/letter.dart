/// One letter at the counter: the stamps on sale, and the postage owed.
class Letter {
  const Letter({
    required this.name,
    required this.cheap,
    required this.dear,
    required this.amount,
    required this.payable,
    this.note,
  });

  final String name;

  /// The two stamp values, coprime.
  final int cheap;
  final int dear;

  /// The postage owed, in pence.
  final int amount;

  /// Whether it can be paid at all. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final bool payable;

  /// A sentence of its own this letter has earned, said after the why,
  /// or null for the letters whose story is the usual one.
  final String? note;
}
