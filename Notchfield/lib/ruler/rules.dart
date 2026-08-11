/// The law of the ruler.
///
/// A ruler runs from nought to its length, and notches sit on whole
/// marks. Every pair of notches measures the distance between them. A
/// ruler is sound when no length is measured twice, and perfect when,
/// besides, every length from one to the whole is measured.
///
/// What can be cut is known by a sweep of every placing of the
/// notches, and the census of distances is the live half of the same
/// arithmetic.
class Rules {
  Rules(this.length);

  final int length;

  /// How often each length is measured: index by distance, nought
  /// unused.
  List<int> census(List<int> notches) {
    final counts = List<int>.filled(length + 1, 0);
    for (var one = 0; one < notches.length; one++) {
      for (var other = one + 1; other < notches.length; other++) {
        counts[(notches[one] - notches[other]).abs()]++;
      }
    }
    return counts;
  }

  /// The pairs measuring a given length.
  List<((int, int), (int, int))> clashesAt(
      List<int> notches, int distance) {
    final pairs = <(int, int)>[
      for (var one = 0; one < notches.length; one++)
        for (var other = one + 1; other < notches.length; other++)
          if ((notches[one] - notches[other]).abs() == distance)
            (notches[one], notches[other]),
    ];
    return [
      for (var one = 0; one < pairs.length; one++)
        for (var other = one + 1; other < pairs.length; other++)
          (pairs[one], pairs[other]),
    ];
  }

  /// Whether no length is measured twice.
  bool isSound(List<int> notches) =>
      census(notches).every((count) => count <= 1);

  /// Whether every length from one to the whole is measured, once.
  bool isPerfect(List<int> notches) {
    final counts = census(notches);
    for (var distance = 1; distance <= length; distance++) {
      if (counts[distance] != 1) return false;
    }
    return true;
  }

  /// Every placing of so many notches, swept.
  Iterable<List<int>> allCuttings(int notches) sync* {
    yield* _cut(notches, 0, const []);
  }

  Iterable<List<int>> _cut(
      int left, int from, List<int> held) sync* {
    if (left == 0) {
      yield held;
      return;
    }
    for (var mark = from; mark <= length - left + 1; mark++) {
      yield* _cut(left - 1, mark + 1, [...held, mark]);
    }
  }

  /// How many placings are sound, and how many perfect.
  (int, int) countCuttings(int notches) {
    var sound = 0;
    var perfect = 0;
    for (final cutting in allCuttings(notches)) {
      if (isSound(cutting)) {
        sound++;
        if (isPerfect(cutting)) perfect++;
      }
    }
    return (sound, perfect);
  }

  /// The sound placings themselves, perfect only if asked.
  List<List<int>> soundCuttings(int notches, {required bool perfect}) => [
        for (final cutting in allCuttings(notches))
          if (perfect ? isPerfect(cutting) : isSound(cutting))
            [...cutting],
      ];
}
