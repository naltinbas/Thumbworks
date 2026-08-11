/// A yard of paddocks, and the round the colt is asked to ride.
///
/// The colt jumps the way a knight moves: two paddocks one way and one the
/// other, gates at the corners it crosses. A round rides through every
/// paddock exactly once. An open round may end anywhere; a closed round
/// must end a single jump from where it began, so the colt can jump home.
class Yard {
  const Yard({
    required this.name,
    required this.width,
    required this.height,
    required this.closed,
    required this.possible,
    this.starts,
    this.note,
  });

  final String name;

  final int width;
  final int height;

  /// Whether the round must come home.
  final bool closed;

  /// Whether any such round exists at all. Written down here as well as
  /// worked out, so a test can hold the two against each other.
  final bool possible;

  /// Where the colt must start, as a paddock index, or null for anywhere.
  final int? starts;

  /// A sentence of its own this yard has earned, said after the why, or
  /// null for the yards whose story is the usual one.
  final String? note;

  int get paddocks => width * height;

  /// Dark paddocks, counting the corner dark: the majority colour on odd
  /// yards.
  int get darks => (paddocks + 1) ~/ 2;
  int get lights => paddocks ~/ 2;
}
