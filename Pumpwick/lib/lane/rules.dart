/// Houses along a lane and a pump to put somewhere on it. Everybody
/// walks to the pump and back, so what matters is the distances added
/// up.
///
/// The walking is least when the pump stands at the middle house: the
/// median, not the average. Step the pump one spot along and the total
/// changes by the houses left behind less the houses ahead, so it is
/// worth moving while more houses lie ahead than behind, and the moving
/// stops where the two counts even out. With an odd count of houses
/// that is the middle house exactly; with an even count every spot
/// between the two middle houses does as well as any other.
class Rules {
  /// The spots on the lane, numbered from the near end.
  static const spots = 13;

  /// Where the pump starts.
  static const start = 0;

  static bool onLane(int spot) => spot >= 0 && spot < spots;

  /// How far everybody walks in all when the pump stands at [spot].
  static int walk(List<int> houses, int spot) {
    var total = 0;
    for (final house in houses) {
      total += (house - spot).abs();
    }
    return total;
  }

  /// The least walking any spot gives, by trying every spot: the first
  /// voice.
  static int leastWalk(List<int> houses) {
    var least = -1;
    for (var spot = 0; spot < spots; spot++) {
      final got = walk(houses, spot);
      if (least < 0 || got < least) least = got;
    }
    return least;
  }

  /// The spots that give it.
  static List<int> bestSpots(List<int> houses) {
    final least = leastWalk(houses);
    return [
      for (var spot = 0; spot < spots; spot++)
        if (walk(houses, spot) == least) spot,
    ];
  }

  /// The middle houses, which is where the walking is least: the second
  /// voice, which adds up nothing. With an odd count it is one spot,
  /// with an even count every spot from the lower middle house to the
  /// upper one.
  static List<int> middleSpots(List<int> houses) {
    final sorted = List.of(houses)..sort();
    final n = sorted.length;
    if (n.isOdd) return [sorted[n ~/ 2]];
    final low = sorted[n ~/ 2 - 1], high = sorted[n ~/ 2];
    return [for (var spot = low; spot <= high; spot++) spot];
  }

  /// How the total changes on stepping from [spot] to the spot one
  /// further along: the houses at or behind it less the houses ahead.
  static int stepChange(List<int> houses, int spot) {
    var behind = 0, ahead = 0;
    for (final house in houses) {
      if (house <= spot) {
        behind++;
      } else {
        ahead++;
      }
    }
    return behind - ahead;
  }

  /// The average of the houses, times the count, so that it stays a
  /// whole number: the pump is not put here, and the game says why.
  static int sumOf(List<int> houses) =>
      houses.fold(0, (total, house) => total + house);

  /// Where the average falls, rounded to the nearest spot.
  static int averageSpot(List<int> houses) =>
      ((2 * sumOf(houses) + houses.length) ~/ (2 * houses.length))
          .clamp(0, spots - 1);

  /// Every row of houses of [count] houses on the lane, each row in
  /// order along it so that the same houses are not counted twice.
  static Iterable<List<int>> rows(int count) sync* {
    final row = List.filled(count, 0);

    Iterable<List<int>> go(int at, int from) sync* {
      if (at == count) {
        yield List.of(row);
        return;
      }
      for (var spot = from; spot < spots; spot++) {
        row[at] = spot;
        yield* go(at + 1, spot);
      }
    }

    yield* go(0, 0);
  }

  static String tellHouses(List<int> houses) => houses.join(', ');

  static String tellSpots(List<int> spots) => spots.join(', ');
}
