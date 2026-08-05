import 'countries.dart';
import 'fewest.dart';
import 'hills.dart';

/// A country being lit.
///
/// Which hills have a beacon on them, and nothing else. What is lit, what is
/// dark and how it compares with the fewest all come out of that and the
/// country.
class Play {
  const Play._(this.watchland, this.country, this.beacons, this.changes);

  factory Play.of(Watchland watchland) =>
      Play._(watchland, watchland.country, const [], 0);

  final Watchland watchland;
  final Country country;

  /// The hills with a beacon on them, in the order they were lit.
  final List<int> beacons;

  /// How many beacons have been put up or taken down.
  final int changes;

  int get count => country.count;

  bool hasBeacon(int hill) => beacons.contains(hill);

  /// What the beacons light between them, as bits.
  int get lit => country.litBy(beacons);

  bool isLit(int hill) => lit & (1 << hill) != 0;

  /// The hills nothing can see.
  List<int> get dark => [
        for (var hill = 0; hill < count; hill++)
          if (!isLit(hill)) hill,
      ];

  bool get isDone => dark.isEmpty;

  /// How many more beacons are up than the fewest there are.
  int get over => beacons.length - watchland.fewest;

  bool get isFewest => isDone && beacons.length == watchland.fewest;

  /// This country with a beacon put up or taken down.
  Play turn(int hill) {
    if (hill < 0 || hill >= count) return this;
    return Play._(
      watchland,
      country,
      beacons.contains(hill)
          ? [for (final one in beacons) if (one != hill) one]
          : [...beacons, hill],
      changes + 1,
    );
  }

  Play get again => Play.of(watchland);

  /// The fewest beacons there are, and where to put them.
  Watch get answer => Beacons.fewestFor(country);

  /// A hill that has a beacon on it in the answer and none here.
  int? get next {
    final want = answer.where;
    for (final hill in want) {
      if (!beacons.contains(hill)) return hill;
    }
    return null;
  }
}
