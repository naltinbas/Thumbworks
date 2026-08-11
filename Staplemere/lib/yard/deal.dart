/// A morning at the woolstapler's yard.
///
/// The bales come up the lane one at a time, in an order the carter chose,
/// and each is weighed in tods as it arrives. A bale may rest on the ground,
/// or on top of a heavier bale, and nothing else: wool crushes, so lighter
/// always sits on heavier. Once a bale is set down it stays.
///
/// The question is the fewest piles the whole morning can end in.
class Deal {
  const Deal({
    required this.name,
    required this.tods,
    required this.fewest,
    this.note,
  });

  final String name;

  /// The weights in the order they come up the lane, all different. Wool was
  /// really weighed in tods, twenty eight pounds to the tod.
  final List<int> tods;

  /// The fewest piles this deal can end in, however well it is played.
  /// Written down here as well as worked out, so a test can hold the two
  /// against each other.
  final int fewest;

  /// A sentence of its own this deal has earned, said after the why, or
  /// null for the deals whose story is the usual one.
  final String? note;

  int get many => tods.length;
}
