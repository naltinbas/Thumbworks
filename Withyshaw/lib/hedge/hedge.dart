/// One hedge: the stalks as the hedger left them.
class Hedge {
  const Hedge({
    required this.name,
    required this.stalks,
    required this.winnable,
    this.note,
  });

  final String name;

  /// Each stalk as (withies-as-bits-from-the-ground, length): set bits
  /// are yours, clear the hedger's.
  final List<(int, int)> stalks;

  /// Whether you, cutting first, hold the hedge. Written down here as
  /// well as worked out, so a test can hold the two against each other.
  final bool winnable;

  /// A sentence of its own this hedge has earned, said after the why, or
  /// null for the hedges whose story is the usual one.
  final String? note;
}
