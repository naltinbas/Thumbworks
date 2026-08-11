/// A ring of children, a rhyme, and a merciless count.
///
/// The dip: everyone stands in a ring, the dipper chants the rhyme round
/// it, one child to a beat, starting from the dip stone and going the way
/// of the sun. Whoever the last beat lands on steps out, the rhyme starts
/// again on the next child still in, and the last one standing is safe.
class Ring {
  const Ring({
    required this.name,
    required this.children,
    required this.rhyme,
    required this.safe,
    this.note,
  });

  final String name;

  /// How many stand in the ring. Seats are counted from the dip stone,
  /// seat 1 being where the count begins.
  final int children;

  /// The rhyme, one word to a beat. Its length is everything and its words
  /// are the fun.
  final List<String> rhyme;

  /// The seat that is last in, counted from the dip stone. Written down
  /// here as well as worked out, so a test can hold the two against each
  /// other.
  final int safe;

  /// A sentence of its own this ring has earned, said after the why, or
  /// null for the rings whose story is the usual one.
  final String? note;

  int get beats => rhyme.length;
}
