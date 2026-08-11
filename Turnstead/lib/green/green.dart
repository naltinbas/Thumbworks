/// One card to write: so many sides, so many rounds allowed.
class Green {
  const Green({
    required this.name,
    required this.sides,
    required this.rounds,
    required this.possible,
    this.note,
  });

  final String name;

  /// Sides on the green, always even.
  final int sides;

  /// Rounds the card may use.
  final int rounds;

  /// Whether the card can be written at all. Written down here as well
  /// as worked out, so a test can hold the two against each other.
  final bool possible;

  /// A sentence of its own this green has earned, said after the why,
  /// or null for the greens whose story is the usual one.
  final String? note;

  int get pairs => sides * (sides - 1) ~/ 2;
}
