/// One hill: what it is called, and where it sits when drawn.
class Hill {
  const Hill(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a country is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// The country: hills, and which of them are within sight of which.
///
/// A beacon on a hill is seen from that hill and from every hill it looks
/// out on. That is the whole rule, and everything else in this game follows
/// from it.
class Country {
  Country({required this.hills, required List<(int, int)> sightlines})
      : sightlines = List.unmodifiable(sightlines) {
    _seen = List.filled(hills.length, 0);
    for (var hill = 0; hill < hills.length; hill++) {
      _seen[hill] = 1 << hill;
    }
    for (final (one, other) in sightlines) {
      _seen[one] |= 1 << other;
      _seen[other] |= 1 << one;
    }
  }

  final List<Hill> hills;

  /// Each pair of hills that can see each other, once.
  final List<(int, int)> sightlines;

  late final List<int> _seen;

  int get count => hills.length;

  /// The hills a beacon here would light, as bits, itself included.
  int lights(int hill) => _seen[hill];

  /// Whether two hills look out on each other.
  bool sees(int one, int other) => _seen[one] & (1 << other) != 0;

  /// Every hill lit, as bits.
  int get all => (1 << count) - 1;

  /// What a set of beacons lights between them.
  int litBy(Iterable<int> beacons) {
    var lit = 0;
    for (final hill in beacons) {
      lit |= _seen[hill];
    }
    return lit;
  }

  bool isWholeCountryLit(Iterable<int> beacons) => litBy(beacons) == all;
}
